xquery version "3.0";

module namespace game = "xlink/game";
import module namespace websocket = "http://basex.org/modules/Ws";
import module namespace request = "http://exquery.org/ns/request";
import module namespace ws = "xlink/WS" at "blackjack_ws.xqm";
import module namespace helper = "xlink/helper" at "helper.xqm";
import module namespace moves = "xlink/moves" at "gameMoves.xqm";


declare variable $game:database := db:open('xlink_blackjack')/database;



declare 
%rest:path('xlink/leave/{$gameID}/{$userID}')
%updating
function game:leave($gameID, $userID){

    let $game := $game:database/gameList//game[@id = $gameID]
    let $gameState := $game/gameInfo/state
    let $player := $game//player[./info/userID = $userID]
    let $user := $game:database/userList//user[@userID = $userID]

    (: Get score of leaving player, update  gamesPlayed, highscore and score:)
    (: Score will only be updated when game is in 'roundFinished' state, otherwise
    the player won't get his score/highscore from current round:)
    let $score := if ($gameState = 'roundFinished') 
                    then moves:getNewScore($player)
                    else $player/info/score/text()

    let $highscore := if ($score > $user/highscore) then $score
                        else $user/highscore

    let $score := round(($user/score/text() + $score) div  2)
    let $gamesPlayed := $user/gamesPlayed + 1

    let $user := 
        (:Update the user stats with results:)
        copy $tmp := $user
        modify(
            replace value of node $tmp/highscore with $highscore,
            replace value of node $tmp/score with $score,
            replace value of node $tmp/gamesPlayed with $gamesPlayed
        )
        return $tmp

    (: Check if leaving Player is currently active. 
    If yes, make next Player active, if not continue:)
    let $playerActive := $game//player[./info/userID = $userID]/info/isActive
    let $game  :=   if ($playerActive = 'true') 
                    then moves:nextPlayerNextState($game, $userID)
                    else $game

    (: Remove leaving player from still playing players:)
    let $players := 
        copy $tmp := $game/players
        modify(delete node $tmp//player[./info/userID = $userID])
        return $tmp

    (: Re-index the players that are still left in the game:)
    let $players := 
        <players>
            {for $player at $index in $players//player
                let $newPlayer :=
                    copy $tmp := $player
                    modify(replace value of node $tmp/@player_id with $index)
                    return $tmp
                return $newPlayer
            }
        </players>

    (:Update the Player Cound:)
    let $newPlayerCount := count($players//player)

    (: If the last player of the game leaves, game will be reset to 'betting' state  :)
    let $game := if ($newPlayerCount = 0) 
        then
            let $newGame :=
                copy $tmp := $game
                modify(
                    replace value of node $tmp/gameInfo/state with 'betting',
                    replace node  $tmp/dealer/cards with <cards />,
                    replace value of node $tmp/dealer/info/handValue with 0,
                    replace value of node $tmp/dealer/info/busted with 'false'
                )
                return $tmp
            return $newGame
        else $game

    (: Update the game with the new players object and update activePlayer Cound:)
    let $game := 
        copy $tmp := $game
        modify(
            replace node $tmp/players with $players,
            replace value of node $tmp/gameInfo/numActivePlayers with $newPlayerCount
        )
        return $tmp

    let $wsIDs := 
        for $wsID in ws:getIDs()
        where ws:get($wsID, 'position') = 'game'
            and ws:get($wsID, 'gameID') = $gameID
        return ws:get($wsID, 'userID')
    
    (: Update database with updated game and updated player object.
    Redirect the leaving player to the lobby and push a new html version
    to the player that are still in the game:)
    let $gameWithPositions := game:appendPositionMapping($game)
    return(update:output(
    for $wsID in $wsIDs
        return
        if ($wsID = $userID) then
            web:redirect(concat('/xlink/lobby/', $userID))
        else  
            let $isActive := $game//player[info/userID = $wsID]/info/isActive
            let $username := helper:getUsername($userID)
            let $params := map {'userID' : $wsID, 'username' : $username, 'isActive' : $isActive}
            let $template := fn:doc('../XSL/BlackJack.xsl')
            let $content := xslt:transform($gameWithPositions, $template, $params)

            let $destinationPath := concat('/xlink/game/', $gameID, '/', $wsID)
            return (ws:send($content, $destinationPath))
    ),
    replace node $game:database/userList//user[@userID = $userID] with $user,
    replace node $game:database//game[@id  = $gameID]  with $game
    )

};

declare 
%rest:path('xlink/drawGame/{$gameID}/{$userID}')
%rest:GET
function game:drawGame($gameID, $userID){
    let $game := $game:database/gameList//game[@id = $gameID]
    
    let $playerListIDs  := $game//player/info/userID
    let $game := game:appendPositionMapping($game)

    let $wsIDs := 
        for $wsID in ws:getIDs()
        where ws:get($wsID, 'position') = 'game'
            and ws:get($wsID, 'gameID') = $gameID
        return ws:get($wsID, 'userID')

    for $wsID in $wsIDs
        let $userID := $wsID
        let $isActive := $game//player[info/userID = $userID]/info/isActive
        let $username := helper:getUsername($userID)
        let $params := map {'userID' : $userID, 'username' : $username, 'isActive' : $isActive}
        let $template := fn:doc('../XSL/BlackJack.xsl')
        let $content := xslt:transform($game, $template, $params)

        let $destinationPath := concat('/xlink/game/', $gameID, '/', $userID)
        return (ws:send($content, $destinationPath))

};


declare
%rest:path('xlink/game/{$gameID}/{$userID}')
%output:method('xhtml')
%rest:GET
function game:getGame($gameID, $userID){
    let $hostname := request:hostname()
    let $port := request:port()
    let $address := concat($hostname,":",$port)
    let $websocketURL := concat("ws://",$address,"/ws/xlink/game")
    let $getURL := concat("http://", $address, "/xlink/drawGame/", $gameID, '/', $userID)
    let $subscription := concat("/xlink/game/",$gameID, '/', $userID)
    let $html :=
        <html>
            <head>
                <title>xlink Blackjack</title>
                <script src="/static/xlink_blackjack/JS/jquery-3.2.1.min.js"></script>
                <script src="/static/xlink_blackjack/JS/stomp.js"></script>
                <script src="/static/xlink_blackjack/JS/ws-element.js"></script>

                <link rel='stylesheet' href='/static/xlink_blackjack/CSS/design.css' />

                <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
                <link
                    rel="stylesheet"
                    href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"
                    integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"
                    crossorigin="anonymous"/>
            </head>
            <body style='background-color: darkred'>
                <ws-stream id = "xlink_blackjack" url="{$websocketURL}" subscription = "{$subscription}" geturl = "{$getURL}" />
            </body>
        </html>

    return $html  
};

declare 
%rest:path('xlink/join/{$gameID}/{$userID}')
%rest:GET
%updating
function game:joinGame($gameID, $userID){
    let $game := $game:database/gameList//game[@id = $gameID]
    let $currentPlayerCount := count($game//player)
    let $maxPlayerCount := $game/gameInfo/numPlayers

    return 
    
    if  ($game//player/info/userID = $userID) then
        update:output(
            web:redirect(concat('/xlink/game/', $gameID, '/', $userID))
        )
    else if ($currentPlayerCount >= $maxPlayerCount) then
    
        update:output(
        web:redirect(concat('/xlink/lobby/', $userID))
        )

    
    
    else
        let $anyoneActive := $game//player[./info/isActive = 'true']
        let $gameState  := $game/gameInfo/state
        let $newPlayer :=
            <player player_id='{$currentPlayerCount + 1}'>
                <info>
                    <username>{helper:getUsername($userID)}</username>
                    <userID>{$userID}</userID>
                    <newInGame>{if (not($anyoneActive)) then 'false' else 'true'
                    }</newInGame>
                    <isActive>{
                        if (not($anyoneActive) and not($gameState = 'waiting')) then 'true'
                        else 'false'
                    }</isActive>
                    <bet>0</bet>
                    <money>100</money>
                    <startMoney>100</startMoney>
                    <handValue>0</handValue>
                    <busted>false</busted>
                    <score>100</score>
                    <result>0</result>
                </info>
                <cards />
                <coins />
            </player>
        
        let $newGame :=
            copy $tmp := $game
            modify(
                insert node $newPlayer as last into $tmp/players,
                replace value of node $tmp/gameInfo/numActivePlayers with $currentPlayerCount + 1
            )
            return $tmp

        return(
        update:output(
            web:redirect(concat('/xlink/game/', $gameID, '/', $userID))
        ),
        replace node $game with $newGame
        )

};



declare function game:appendPositionMapping($game){
    let $mapping :=
    <positions>
        <pos nr='1'>
            <cardArea x='12' y='12' />
            <cardShape x='12' y='24' />
            <cardColor x='13.6' y='26.5' />
            <cardValueTop x='12.5' y='28.2' />
            <cardValueBottom x='14.8' y='47' />
            <firstCoin x='12' y='80'  />
            <nameArea x='13' y='8' />
            <moneyArea x='13' y='11' />
        </pos>
        <pos nr='2'>
            <cardArea x='24' y='46' />
            <cardShape x='24' y='92' />
            <cardColor x='26.8' y='102' />
            <cardValueTop x='24.5' y='97' />
            <cardValueBottom x='26.8' y='115' />
            <firstCoin x='24' y='150'  />
            <nameArea x='25' y='42' />
            <moneyArea x='25' y='45' />
        </pos>
        <pos nr='3'>
            <cardArea x='39' y='60' />
            <cardShape x='39' y='100' />
            <cardColor x='43.7' y='110.9' />
            <cardValueTop x='39.5' y='105' />
            <cardValueBottom x='42' y='122.5' />
            <firstCoin x='39.5' y='160'  />
            <nameArea x='40' y='46' />
            <moneyArea x='40' y='49' />
        </pos>
        <pos nr='4'>
            <cardArea x='54' y='60' />
            <cardShape x='54' y='100' />
            <cardColor x='60.3' y='110.9' />
            <cardValueTop x='54.5' y='105' />
            <cardValueBottom x='57.2' y='122.5' />
            <firstCoin x='54.5' y='160'  />
            <nameArea x='55' y='46' />
            <moneyArea x='55' y='49' />
        </pos>
        <pos nr='5'>
            <cardArea x='69' y='46' />
            <cardShape x='69' y='92' />
            <cardColor x='76.7' y='101' />
            <cardValueTop x='69.5' y='96' />
            <cardValueBottom x='71.7' y='115' />
            <firstCoin x='70' y='150'  />
            <nameArea x='70' y='42' />
            <moneyArea x='70' y='45' />
        </pos>
        <pos nr='6'>
            <cardArea x='81' y='12' />
            <cardShape x='81' y='24' />
            <cardColor x='89.9' y='25' />
            <cardValueTop x='81.5' y='28.2' />
            <cardValueBottom x='83.8' y='46.9' />
            <firstCoin x='81' y='80'  />
            <nameArea x='82' y='8' />
            <moneyArea x='82' y='11' />
        </pos>
    </positions>

    let $gameWithPositionMapping := 
        copy $tmp := $game
        modify(insert node $mapping into $tmp)
        return  $tmp

    return $gameWithPositionMapping
};