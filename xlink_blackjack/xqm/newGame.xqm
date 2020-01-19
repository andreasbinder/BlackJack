xquery version "3.0";

module namespace ng = "xlink/newGame";
import module namespace helper = "xlink/helper" at "helper.xqm";

declare variable $ng:database := db:open('xlink_blackjack')/database;

declare
%rest:path('xlink/newGame/{$userID}')
%rest:GET
%output:method('xhtml')
function ng:createGame($userID as xs:string){
    let $template := fn:doc('../XSL/newGame.xsl')
    let $data := $ng:database/userList
    let $params := map {'userID' : $userID}
    let $content := xslt:transform($data, $template, $params)
        
    let $xhtml := ng:applyTemplate($content)
    return $xhtml
};


declare
%rest:path('xlink/newGame/{$userID}')
%rest:POST
%rest:form-param('gameName', '{$gameName}')
%rest:form-param('numStacks', '{$numStacks}')
%rest:form-param('numPlayers', '{$numPlayers}')
%updating
function ng:createNewGame($userID, $gameName, $numStacks, $numPlayers){
    let $gameID := ng:createID($gameName)
    let $cardStack := ng:initCardStack($numStacks)
    let $newGame := ng:getNewGameTemplate($gameID, $cardStack, $numPlayers, $userID)

    return (
        ng:insertNewGame($newGame),
        update:output(
            web:redirect(concat('/xlink/lobby/', $userID))
        )
    )
};

declare
%private
%updating
function ng:insertNewGame($game){
    insert node $game as first into $ng:database/gameList
};

declare
%private
function ng:getNewGameTemplate($gameID, $cardStack, $numPlayers, $userID) {  
    let $username := helper:getUsername($userID)
    return
    <game id='{$gameID}'>
        <gameInfo>
            <state>waiting</state>
            <numPlayers>{if ($numPlayers) then $numPlayers else 6}</numPlayers>
            <numActivePlayers>0</numActivePlayers>
            <createdBy>
                <userID>{$userID}</userID>
                <username>{$username}</username>
            </createdBy>
        </gameInfo>
        <dealer>
            <info>
                <handValue>0</handValue>
                <busted>false</busted>
            </info>
            <cards/>
        </dealer>
        <players />
        {$cardStack}
    </game>
};

declare
%private
function ng:createID($gameName){
    let $timestamp := helper:timestamp()
    return if($gameName) then
        concat($gameName, '_', $timestamp)
    else
        concat('new_game_', $timestamp)
};

declare 
%private
function ng:initCardStack($numStacks){
    let $num := if ($numStacks) then $numStacks else 5
    return 
    <cardStack>
        {for $i in (1 to $num)
            return  
                doc('../cardStack.xml')//card
        }
    </cardStack>
};

declare %private function ng:applyTemplate($content){
    <html>
        <head>
            <meta charset='utf-8' />
            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
            <link
                rel="stylesheet"
                href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"
                integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"
                crossorigin="anonymous"/>
            <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
            <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
        </head>
        <body style='background-color: darkred;'>
            <div style='padding-bottom: 50px;'>
                {$content}
            </div>
        </body>
    </html>
};