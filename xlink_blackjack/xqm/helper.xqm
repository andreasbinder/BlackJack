xquery version "3.0";

module namespace helper = "xlink/helper";
declare variable $helper:database := db:open('xlink_blackjack')/database;


(: finds the username that belongs to a userID:)
declare function helper:getUsername($userID){
    $helper:database//user[@userID = $userID]/username/text()
};

declare function helper:random($range as xs:integer) as xs:integer {
    (: returns a random number in [1,$range] :)
    (: uses Java function until generate-random-number is generally available :)
    xs:integer(ceiling(Q{java:java.lang.Math}random() * $range))
};

declare function helper:timestamp() as xs:string {
    (: returns a timestamp in the form hhmmssmmm (hours, minutes, seconds, milliseconds) :)
    (: removes ":" and "." separators and time zone info from current-time() :)
    let $time := replace(replace(replace(string(current-time()),":",""),"\.",""),"[\+\-].*","")
    return $time
};

(:wraps the passed html body content into a standard html file with header and the needed
javascript and stylesheet ressources :)
declare function helper:applyWrapper($content){
    <html>
        <head>
            <title> Blackjack - Xlink </title>
            <script src="/static/tictactoe/JS/jquery-3.2.1.min.js"></script>
            <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
            <link
                rel="stylesheet"
                href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"
                integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"
                crossorigin="anonymous"/>
        </head>
        <body style='background-color: darkred'>
          {$content}
        </body>
    </html>
};