xquery version "3.0";

module namespace lobby = "xlink/lobby";
import module namespace ws = "xlink/WS" at "blackjack_ws.xqm";
import module namespace helper = "xlink/helper" at "helper.xqm";
import module namespace request = "http://exquery.org/ns/request";


declare variable $lobby:database := db:open('xlink_blackjack')/database;



declare 
%rest:path('xlink/drawLobby/{$userID}')
%rest:GET
function lobby:drawLobby($userID){
    (: Creates and renders the lobby. The Result is pushed to every client
    that is currently subscribed to the lobby:)
    let $data := $lobby:database/gameList
    
    (:small stat to improve UX:)
    let $userCountGame := count(
        for $wsID in ws:getIDs()
        where ws:get($wsID, 'position') = 'game'
        return $wsID
    )
    
    (:small stat to improve UX:)
    let $userCountLobby := count(
        for $wsID in ws:getIDs()
        where ws:get($wsID, 'position') = 'lobby'
        return $wsID
    )
    return
        (:push the lobby html to every client that subscribed to lobby' via websocket:)
        (for $wsID in ws:getIDs()
            where ws:get($wsID, 'position') = 'lobby'
            let $userID := ws:get($wsID, 'userID')
            let $username := helper:getUsername($userID)
            let $params := map {'userID' : $userID, 'username' : $username, 'userCountLobby' : $userCountLobby, 'userCountGame' : $userCountGame}
            let $template := fn:doc('../XSL/lobby.xsl')
            let $content := xslt:transform($data, $template, $params)
            let $destinationPath := concat('/xlink/lobby/', $userID)
            return (ws:send($content, $destinationPath))
        )
};

declare
%rest:path('/lobby/{$userID}/delete/{$gameID}')
%rest:GET
%output:method('xhtml')
%updating
function lobby:deleteGame($userID, $gameID){
    (: the function deletes a game specified by the gameID. The user gets
    redirected to '/lobby' and therefore triggers a rerender for all clients:)
    (: TODO-maybe: check if user actually created the game. At the moment,
    this is only checked in the front-end. If he  didn't create the game,
    the button is  not visible:)
    let $games := $lobby:database/gameList
    let $nextGames := 
        copy $tmp := $games
        modify(
            delete node $tmp//game[@id=$gameID]
        )
        return $tmp
    return (
        replace node $games with $nextGames,
        update:output(web:redirect(concat('/xlink/lobby/', $userID)))
    )
};

declare
%rest:path('xlink/lobby/{$userID}')
%output:method('xhtml')
%rest:GET
function lobby:getLobby($userID as xs:string){
    let $hostname := request:hostname()
    let $port := request:port()
    let $address := concat($hostname,":",$port)
    let $websocketURL := concat("ws://",$address,"/ws/xlink/lobby")
    let $getURL := concat("http://", $address, "/xlink/drawLobby/", $userID)
    let $subscription := concat("/xlink/lobby/",$userID)
    let $html :=
        <html>
            <head>
                <title>xlink Blackjack Lobby</title>
                <script src="/static/xlink_blackjack/JS/jquery-3.2.1.min.js"></script>
                <script src="/static/xlink_blackjack/JS/stomp.js"></script>
                <script src="/static/xlink_blackjack/JS/ws-element.js"></script>

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
%rest:path('xlink/lobby/leaderboard/{$userID}')
%rest:GET
%output:method('xhtml')
function lobby:getLeaderboard($userID){
    let $data := $lobby:database/userList

    let $params := map {'userID' : $userID}
    let $template := fn:doc('../XSL/leaderboard.xsl')
    let $content := xslt:transform($data, $template, $params)
    return helper:applyWrapper($content)
};


declare
%rest:path('xlink/lobby/docbook/{$userID}')
%rest:GET
%output:method('xhtml')
function lobby:getDocBook($userID){
    (:let $params := map {'userID' : $userID}
    let $content := fn:doc('./XSL/docbook.xsl')
    let $xhtml := helper:applyWrapper($content) 
    return $xhtml:)
    let $data := $lobby:database/userList

    let $params := map {'userID' : $userID}
    let $template := fn:doc('../XSL/docbook.xsl')
    let $content := xslt:transform($data, $template, $params)
    return helper:applyWrapper($content)
};



declare
%rest:path('xlink')
%output:method('xhtml')
%rest:GET
function lobby:start(){
    let $content := fn:doc('../XSL/login.xsl')
    let $xhtml := helper:applyWrapper($content) 
    return $xhtml
};

declare
%rest:path('xlink/login')
%rest:POST
%rest:form-param('username', '{$username}')
%rest:form-param('password', '{$password}')
function lobby:login($username, $password){
    let $userList := db:open('xlink_blackjack')//userList
    let $user := $userList//user[./username = $username]


    let $redirect := 
        if ($user) then
            if ($user/password = $password) then
                concat('/xlink/lobby/', $user/@userID)
            else '/xlink'
        else '/xlink'
    
    return web:redirect($redirect)
};

declare
%rest:path('xlink/register')
%rest:POST
%rest:form-param('username', '{$username}')
%rest:form-param('password', '{$password}')
%updating
function lobby:register($username, $password){
    (:The function used to register a user. A new user object is created with username,
    password, gamesPlayed, score and highscore. The  new object is inserted into the database
    and the user gets redirected to the lobby. If the user already exists, he gets redirected
    to the login/register site again. For further improvement, a message could be sent to tell
    the user why his registration didn't work :)
    let $userList := db:open('xlink_blackjack')//userList
    let $user := $userList//user[./username = $username]

    let $newUser :=  
        if ($user) then ()
        else
            let $userID := helper:timestamp()
            return
                <user userID='{$userID}'>
                    <username>{$username}</username>
                    <password>{$password}</password>
                    <gamesPlayed>0</gamesPlayed>
                    <score>100</score>
                    <highscore>0</highscore>
                </user>
    return
        if ($newUser) then
            (update:output(web:redirect(concat('/xlink/lobby/',$newUser/@userID))), lobby:insertNewUser($newUser))
        else
            (update:output(web:redirect('/xlink')))
};


declare
%updating
function lobby:insertNewUser($user){
    (: inserts the new user object into the userList in the database:)
    insert node $user as first into db:open('xlink_blackjack')//userList
};