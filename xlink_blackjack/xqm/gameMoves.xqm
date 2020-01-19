xquery version "3.0";

module namespace moves = "xlink/moves";

import module namespace websocket = "http://basex.org/modules/Ws";
import module namespace request = "http://exquery.org/ns/request";
import module namespace ws = "xlink/WS" at "blackjack_ws.xqm";
import module namespace helper = "xlink/helper" at "helper.xqm";

declare variable $moves:database := db:open('xlink_blackjack')/database;


declare function moves:getNextState($state){
    if ($state = 'waiting') then 'betting'
    else if ($state = 'newRound') then 'betting'
    else if($state = 'betting') then 'initialCards' 
    else if($state = 'initialCards') then 'finishingPlayer' 
    else if($state = 'finishingPlayer') then 'finishingDealer'
    else if($state = 'finishingDealer') then 'roundFinished'
    else if($state = 'roundFinished') then 'newRound'
    else 'state unknown'
};

declare 
%rest:path('/xlink/game/{$gameID}/{$userID}/nextRound')
%rest:POST
%updating
function moves:nextRound($gameID, $userID){
    let $game := $moves:database//game[@id = $gameID]
    let $player := $game//player[info/userID = $userID]

    let $newPlayer := 
        copy $tmp := $player
        modify(
            replace value of node $tmp/info/money with moves:payOutPlayer($player),
            replace value of node $tmp/info/newInGame with 'false',
            replace value of node $tmp/info/bet with 0,
            replace value of node $tmp/info/handValue with 0,
            replace node $tmp/cards with <cards />,
            replace node $tmp/coins with <coins />,
            replace value of node $tmp/info/busted with 'false',
            replace value of node $tmp/info/result with 0,
            replace value of node $tmp/info/score with moves:getNewScore($player)
        )
        return $tmp

    let $newGame := 
        copy $tmp := $game
        modify(
            replace node $tmp//player[info/userID = $userID] with $newPlayer
        )
        return $tmp

    (: when all players are ready (don't have any cards), the next round will
    be open and  therefore the state will be set on 'betting' :)
    let $anyCardCount := count($newGame//player/cards//card)
    let $newState := 
        if ($anyCardCount > 0) then $newGame/gameInfo/state
        else 'betting'

    let $newDealer :=
        if ($newState = 'betting') then 
            <dealer>
                <info>
                    <handValue>0</handValue>
                    <busted>false</busted>
                </info>
                <cards />
            </dealer>
        else $game/dealer

    let $newGame := 
        copy $tmp := $newGame
        modify(
            replace value of node $tmp/gameInfo/state with $newState,
            replace node $tmp/dealer with $newDealer
        )
        return $tmp
    

    (:  When there are less than  50 cards left on the stack, a new stack gets added:)
    let $newGame := 
        if (count($newGame//card) < 50) then 
            copy $tmp := $newGame
            modify(
                insert node doc('cardStack.xml')//card into $tmp/cardStack
            )
            return $tmp
        else $newGame

    return (
        update:output(web:redirect(concat('/xlink/game/', $gameID, '/', $userID))), 
        replace node $game with $newGame
    )

};

declare
function moves:getNewScore($player){
    let $startMoney := $player/info/startMoney
    let $bet := $player/info/bet
    let $money := $player/info/money
    let $result := $player/info/result


    let $currentMoney := $money + $bet * $result
    let $newScore := round(($currentMoney div $startMoney) * 100)

    return xs:integer($newScore)
};

declare
%private
function moves:payOutPlayer($player){
    let $bet := $player/info/bet/text()
    let $money := $player/info/money/text()
    let $result := $player/info/result/text()

    let $newMoney := $money + $bet * $result
    return $newMoney
};

declare
%rest:path('/xlink/game/{$gameID}/{$userID}/start')
%rest:POST
%updating
function moves:startGame($gameID, $userID){
    let $game := $moves:database//game[@id = $gameID]
    let $newPlayers :=
        <players>
            {for $player at $count in $game//player
                let $isActive := if($count = 1) then 'true' else 'false'
                let $newPlayer :=
                    copy $tmp := $player
                    modify(
                        replace value of node $tmp/info/newInGame with 'false',
                        replace value of node $tmp/info/isActive with $isActive
                    )
                    return $tmp
                return $newPlayer
            }
        </players>

    let $newGame :=
        copy $tmp := $game
        modify(
            replace value of node $tmp/gameInfo/state with 'betting',
            replace node $tmp/players with $newPlayers
        )
        return $tmp

    return(
        update:output(
            web:redirect(concat('/xlink/game/', $gameID, '/', $userID))
        ),
        replace node $game with $newGame
    )
};

declare
%rest:path('/xlink/game/{$gameID}/{$userID}/placeBet')
%rest:POST
%rest:form-param('bet_amount', '{$bet_amount}')
%output:method('xhtml')
%updating
function moves:placeBet($gameID, $userID, $bet_amount){
    let $game := $moves:database//game[@id=$gameID]

    let $bet_amount := xs:integer($bet_amount)
    let $coins := moves:getCoins($bet_amount)
    
    let $activePlayer := $game//player[info/isActive='true']/info/userID
    let $state := $game/gameInfo/state

    return 
        if (
            $activePlayer != $userID or 
            $state != 'betting' or $bet_amount < 1) 
        then update:output(web:redirect(concat('/xlink/game/', $gameID, '/', $userID)))
    else
        let $nextGame :=
            copy $tmp := $game
            modify(
                replace value of node $tmp//player[info/userID = $userID]/info/bet with $bet_amount,
                replace node $tmp//player[info/userID = $userID]/coins with $coins,
                replace value of node $tmp//player[info/userID = $userID]/info/money with $tmp//player[info/userID = $userID]/info/money - $bet_amount
            )
            return $tmp

        let $nextGame := moves:nextPlayerNextState($nextGame, $userID)

        return (update:output(web:redirect(concat('/xlink/game/', $gameID, '/', $userID))), 
                replace node $game with $nextGame)
            
};

declare
%rest:path('/xlink/game/{$gameID}/{$userID}/draw2Cards')
%rest:POST
%updating
function moves:draw2Cards($gameID, $userID){
    let $game := $moves:database//game[@id = $gameID]
    let $newGame := moves:drawCardForPlayer($game, $userID)
    let $newGame := moves:drawCardForPlayer($newGame, $userID)
    let $newGame := moves:nextPlayerNextState($newGame, $userID)

    let $newGame := if ($newGame/gameInfo/state = 'finishingPlayer')
                    then moves:drawCardForPlayer($newGame, 'dealer')
                    else $newGame

    return(
        replace node $game with $newGame,
        update:output(web:redirect(concat('/xlink/game/', $gameID, '/', $userID)))
    )
};

declare
%rest:path('/xlink/game/{$gameID}/{$userID}/turn/{$turn}')
%rest:POST
%updating
function moves:gameMove($gameID, $userID, $turn){
    let $game := $moves:database//game[@id=$gameID]
    let $state := $game/gameInfo/state
    let $activePlayer := $game//player[info/isActive='true']
    let $activePlayerID := $activePlayer/info/userID

    return if (
            $activePlayerID != $userID or 
            $state != 'finishingPlayer' )
        then update:output(web:redirect(concat('xlink/game/', $gameID, '/', $userID)))
    else
        let $nextGame := 
            if ($turn = 'doubleDown') then moves:doubleDown($game, $userID)
            else if($turn = 'hit') then moves:hit($game, $userID)
            else if ($turn = 'stand') then moves:stand($game, $userID)
            else $game

        let $nextGame :=
            if ($nextGame/gameInfo/state = 'finishingDealer') then 
                let $nextGame := moves:finishDealer($nextGame)
                let $nextGame := moves:determineWiners($nextGame)
                return $nextGame
            else $nextGame

        return (update:output(web:redirect(concat('/xlink/game/', $gameID, '/', $userID))),
                replace node $game with $nextGame ) 
};

declare 
%private
function moves:determineWiners($game){
    let $dealerBusted := $game/dealer/info/busted

    let $newPlayers := 
        if ($dealerBusted = 'true') then moves:allWin($game)
        else moves:bestWin($game)

    let $nextGame := 
        copy $tmp := $game
        modify(
            replace value of node $tmp/gameInfo/state with 'roundFinished',
            replace node $tmp/players with $newPlayers
        )
        return $tmp

    return $nextGame
};

declare
%private
function moves:bestWin($game){
    let $dealerHandValue := $game/dealer/info/handValue

    let $newPlayers := 
            <players>
                {for $player in $game//player
                    let $result :=
                        <result>
                            {
                                if ($player/info/busted = 'false' and $player/info/newInGame = 'false' ) then
                                    let $playerHandValue := $player/info/handValue
                                    return 
                                        if ($playerHandValue > $dealerHandValue) then 2
                                        else if ($playerHandValue = $dealerHandValue) then 1
                                        else 0

                                else if ($player/info/busted = 'true' and $player/info/newInGame = 'false' ) then
                                    0
                                else -1
                            }
                        </result>

                    let $newPlayer := 
                            copy $tmp := $player
                            modify(
                                replace node $tmp/info/result with $result
                            )
                            return $tmp

                    return $newPlayer
                }
            </players>

    return $newPlayers
};

declare
%private 
function moves:allWin($game){
    <players>
        {for $player in $game//player
            return if ($player/info/busted = 'false' and $player/info/newInGame != 'true' ) then
                let $result := <result>2</result>
                let $newPlayer := 
                    copy $tmp := $player
                    modify(
                        replace node $tmp/info/result with $result
                    )
                    return $tmp
                return $newPlayer
            else if ($player/info/busted = 'true' and $player/info/newInGame != 'true') then
                let $result := <result>0</result>
                let $newPlayer := 
                    copy $tmp := $player
                    modify(
                        replace node $tmp/info/result with $result
                    )
                    return $tmp
                return $newPlayer
            else 
                let $result := <result>-1</result>
                let $newPlayer := 
                    copy $tmp := $player
                    modify(
                        replace node $tmp/info/result with $result
                    )
                    return $tmp
                return $newPlayer
        }
    </players>
};

declare 
%private 
function moves:finishDealer($game){
    let $handValue := $game/dealer/info/handValue

    return if ($handValue >= 17) 
        then $game
        else 
            let $nextGame := moves:drawCardForPlayer($game, 'dealer')
            return moves:finishDealer($nextGame)
};

declare 
%private 
function moves:doubleDown($game, $userID){
    let $player := $game//player[info/userID = $userID]
    let $bet := $player/info/bet
    let $money := $player/info/money
    let $cardCount := count($player/cards//card)

    return 
        if (xs:integer($bet) > xs:integer($money) or $cardCount > 2) then $game
        else
            let $nextBet := $bet * 2
            let $nextMoney := $money - $bet
            let $coins := moves:getCoins($nextBet)
            let $nextGame := 
                copy $tmp := $game
                modify(
                     replace node $tmp//player[info/userID = $userID]/coins with $coins,
                    replace value of node $tmp//player[info/userID = $userID]/info/bet with $nextBet,
                    replace value of node $tmp//player[info/userID = $userID]/info/money with $nextMoney
                )
                return $tmp

            let $nextGame := moves:drawCardForPlayer($nextGame, $userID)
            let $nextGame := moves:nextPlayerNextState($nextGame, $userID)
     
            return $nextGame
};

declare 
%private 
function moves:hit($game, $userID){
    let $nextGame := moves:drawCardForPlayer($game, $userID)

    return 
        if ($nextGame//player[info/userID = $userID]/info/busted = 'false') 
            then $nextGame
        else 
            moves:nextPlayerNextState($nextGame, $userID)
};

declare 
%private 
function moves:stand($game, $userID){
    moves:nextPlayerNextState($game, $userID)
};

declare 
function moves:nextPlayerNextState($game, $userID){
    (: Determines the next Player and sets him as active Player.
    If current move-round is done (e.g. all player placed bet), the state
    of the game will be modified accordingly :)


    (:Retrieve basic info about current game:)
    let $numPlayers := $game/gameInfo/numActivePlayers
    let $currentPlayerID := $game//player[info/userID = $userID]/@player_id

    (: Next Player is determined  by increasing the player_id by one. If currentPlayerID = numPlayers, 
    we know  that we reached the next state:)
    let $nextPlayerID := if ($currentPlayerID = $numPlayers) then 1 else $currentPlayerID + 1
    let $nextPlayerUserID := $game//player[@player_id = $nextPlayerID]/info/userID

    return 
        if ($game//player[@player_id = $nextPlayerID]/info/newInGame = 'true') 
            (: Skip the player that just joins in the middle of the game :)
            then 
                (:mark  current player with isActive=false  and recall the function to get nextPlayer and next State:)
                let $game := 
                    copy $tmp := $game
                    modify(replace value of node $tmp//player[@player_id=$currentPlayerID]/info/isActive with 'false')
                    return $tmp
                    return (moves:nextPlayerNextState($game, $nextPlayerUserID))
        else

            (: Depending on wether we  reached the next  State (when nextPlayer = 1) we get the next state :)
            let $state := $game/gameInfo/state
            let $nextState := if ($nextPlayerID = 1) then moves:getNextState($state) else $state


            (:modify the game with the next state depending on wether we reach next state and activate
            and deactivate the players. When there is only one player in the game we jsut need to  modify the next state
            as he is  the only one that is active:)
            let $nextGame := 
                if ($numPlayers = 1) then
                    copy $tmp := $game
                    modify(
                        replace value of node $tmp/gameInfo/state with $nextState
                    )
                    return $tmp
                else 
                    copy $tmp := $game
                    modify(
                        replace value of node $tmp/gameInfo/state with $nextState,
                        replace value of node $tmp//player[@player_id=$currentPlayerID]/info/isActive with 'false',
                        replace value of node $tmp//player[@player_id=$nextPlayerID]/info/isActive with 'true'
                    )
                    return $tmp
            return $nextGame
};



declare 
%private 
function moves:drawCardForPlayer($game, $userID){
    let $stack := $game/cardStack
    let $stackCount := count($stack//card)
    let $randNum :=  xs:integer(ceiling(Q{java:java.lang.Math}random() * $stackCount))

    return 
        if ($userID = 'dealer') then
            let $nextGame := 
                copy $tmp := $game
                modify(
                    insert node $tmp/cardStack/card[$randNum] as first into $tmp/dealer/cards,
                    delete node $tmp/cardStack/card[$randNum]
                )
                return $tmp

            let $handValue := moves:getHandValue($nextGame/dealer/cards)
            let $busted := if ($handValue > 21) then 'true' else 'false'
            let $nextGame :=
                copy $tmp := $nextGame
                modify(
                    replace value of node $tmp/dealer/info/handValue with $handValue,
                    replace value of node $tmp/dealer/info/busted with $busted
                )
                return $tmp

            return $nextGame

        else
            let $nextGame := 
                copy $tmp := $game
                modify(
                    insert node $tmp/cardStack/card[$randNum] as first into $tmp//player[info/userID=$userID]/cards,
                    delete node $tmp/cardStack/card[$randNum]   
                )
                return $tmp
            
            let $handValue := moves:getHandValue($nextGame//player[info/userID=$userID]/cards)
            let $busted := if ($handValue > 21) then 'true' else 'false'
            let $nextGame :=
                copy $tmp := $nextGame
                modify(
                    replace value of node $tmp//player[info/userID=$userID]/info/handValue with $handValue,
                    replace value of node $tmp//player[info/userID=$userID]/info/busted with $busted
                )
                return $tmp

            return $nextGame
};

declare 
%private 
function moves:getHandValue($cards){
    let $noAceCards := $cards//card[not(@alt_value)]
    let $aceCount := count($cards//card[@alt_value])
    
    let $sum := sum(
        for $card in $noAceCards
        return $card/@value
    )

    let $sum := 
        if ($aceCount > 0) then
            if ($sum + 11 + $aceCount - 1 <= 21) then $sum + 11 + $aceCount -1
            else $sum + $aceCount
        else $sum

    return $sum
};

declare
function moves:getCoins($bet){

    let $fivehundreds := floor($bet div 500)
    let $rest := $bet - ($fivehundreds * 500)

    let $twohundreds := floor($rest div 200)
    let $rest := $rest - ($twohundreds * 200)

    let $hundreds := floor($rest div 100)
    let $rest := $rest - ($hundreds * 100)

    let $fifties := floor($rest div 50)
    let $rest := $rest - ($fifties * 50)

    let $twenties := floor($rest div 20)
    let $rest := $rest - ($twenties * 20)

    let $tens := floor($rest div 10)
    let $rest := $rest - ($tens * 10)

    let $fives := floor($rest div 5)
    let $rest := $rest - ($fives * 5)

    let $twos := floor($rest div 2)
    let $rest := $rest - ($twos * 2)

    let $ones := floor($rest div 1)

    return
        <coins>
            <coin value='500' amount='{$fivehundreds}' />
            <coin value='200' amount='{$twohundreds}' />
            <coin value='100' amount='{$hundreds}' />
            <coin value='50' amount='{$fifties}' />
            <coin value='20' amount='{$twenties}' />
            <coin value='10' amount='{$tens}' />
            <coin value='5' amount='{$fives}' />
            <coin value='2' amount='{$twos}' />
            <coin value='1' amount='{$ones}' />
        </coins>
};
