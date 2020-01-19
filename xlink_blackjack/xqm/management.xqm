xquery version "3.0";

module namespace m = "xlink/management";
import module namespace testwS = "xlink/WS" at "blackjack_ws.xqm";

declare variable $m:database := db:open('xlink_blackjack')/database;

declare
%rest:path("xlink/setup")
%output:method("xhtml")
%updating
%rest:GET
function m:setup(){
    let $model := doc("../xlink_blackjack.xml")
    return(db:create("xlink_blackjack", $model),
    update:output("Database setup"))
};

declare
%rest:path('xlink/data')
%rest:GET
function m:getAllData(){
    $m:database
};

declare
%rest:path('xlink/game/{$gameID}/{$userID}/data')
%rest:GET
function m:getGameData($gameID, $userID){
    $m:database//game[@id = $gameID]
};

declare
%rest:path('xlink/reset')
%output:method("xhtml")
%rest:GET
%updating
function m:reset(){
    let $database := db:open('xlink_blackjack')
    let $userList := <userList />
    let $gameList := <gameList />
    return(
        replace node $database//userList with $userList,
        replace node $database//gameList with $gameList,
        update:output("Database reset"))
};
