xquery version "3.0";

module namespace xlinkws = "xlink/WS";
import module namespace websocket = "http://basex.org/modules/Ws";
import module namespace helper = "xlink/helper" at "helper.xqm";
import module namespace game = "xlink/game" at "game.xqm";



declare
%ws-stomp:connect("/xlink")
function xlinkws:stompconnect(){
    trace(concat("WS client connected with id ", ws:id()))
};

declare
%ws-stomp:connect("/xlink/lobby")
function xlinkws:stompconnectLobby(){
    trace(concat("WS client connected with id ", ws:id()))
};

declare
%ws-stomp:subscribe("/xlink/lobby")
%ws:header-param("param0", "{$group}")
%ws:header-param("param1", "{$position}")
%ws:header-param("param2", "{$userID}")
%updating
function xlinkws:subscribeLobby($group, $position, $userID){
    websocket:set(websocket:id(), "group", $group),
    websocket:set(websocket:id(), "position", $position),
    websocket:set(websocket:id(), "userID", $userID),
    update:output(trace(concat("/xlink/lobby with id ", ws:id(), 
        " and userID ", $userID, " subscribed to ", $group, "/", $position)))
};

declare
%ws-stomp:subscribe("/xlink/game")
%ws:header-param("param0", "{$group}")
%ws:header-param("param1", "{$position}")
%ws:header-param("param2", "{$gameID}")
%ws:header-param("param3", "{$userID}")
%updating
function xlinkws:subscribeGame($group, $position, $gameID, $userID){
    websocket:set(websocket:id(), "group", $group),
    websocket:set(websocket:id(), "position", $position),
    websocket:set(websocket:id(), "gameID", $gameID),
    websocket:set(websocket:id(), "userID", $userID),
    update:output(trace(concat("/xlink/game ",$gameID, "with id ",
        ws:id(), " and userID ", $userID, " subscribed to ", $group, "/", $position)))
};

declare function xlinkws:getIDs(){
    websocket:ids()
};

declare function xlinkws:send($data, $path){
    websocket:sendchannel(fn:serialize($data), $path)
};

declare function xlinkws:get($key, $value){
    websocket:get($key, $value)
};

declare function xlinkws:getPath($ID){
    websocket:path($ID)
};