<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:svg="http://www.w3.org/2000/svg" 
    xmlns:xlink="http://www.w3.org/1999/xlink" version="3.0">

    <xsl:template match="/">




        <xsl:variable name='gameID' select='game/@id' />
        <!--Definieren der Spieler -->
        <xsl:variable name="dealer" select="game/dealer"/>
        <xsl:variable name="player1" select="game/players/player[@player_id = 1]"/>
        <xsl:variable name="player2" select="game/players/player[@player_id = 2]"/>
        <xsl:variable name="player3" select="game/players/player[@player_id = 3]"/>
        <xsl:variable name="player4" select="game/players/player[@player_id = 4]"/>
        <xsl:variable name="player5" select="game/players/player[@player_id = 5]"/>
        <xsl:variable name="player6" select="game/players/player[@player_id = 6]"/>


        <xsl:variable name='state' select='game/gameInfo/state' />
        <xsl:variable name='position' select='game/positions' />
        <xsl:param name='userID' />
        <xsl:param name='username' />
        <xsl:param name='isActive' />
        <xsl:param name='activePlayer' />



        <body>

            <div class='clearfix'>

                <a href='/xlink/leave/{$gameID}/{$userID}' role='button' class='btn btn-primary btn-lg float-left mr-2'> 
                Go back to Lobby 
                </a>

                <h3 class='text-right'>
                Cards on Stack:<xsl:value-of select='count(/game/cardStack//card)' />
                </h3>
            </div>

            <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%">


                <!-- Definitionen -->
                <defs>
                    <g id="CardArea">
                        <rect rx="15" ry="15" width="7%" height="20%" style="fill:green;stroke:white;stroke-width:5;opacity:0.5" />
                    </g>

                    <g id="CoinArea">
                        <circle r="2.8%" fill="green" stroke="white" stroke-width="3" stroke-dasharray="5,5" opacity="0.5"/>
                    </g>
                    <!--Group für Tisch -->
                    <g id="blankTable">

                        <!-- Tischform -->
                        <circle cx="50%" cy="0%" r="64%" fill="green" stroke="brown" stroke-width="5"/>

                        <!-- Plätze für Karten -->
                        <use xlink:href="#CardArea" id="CardArea1" x="12%" y="12%"/>
                        <use xlink:href="#CardArea" id="CardArea2" x="24%" y="46%"/>
                        <use xlink:href="#CardArea" id="CardArea3" x="39%" y="50%"/>
                        <use xlink:href="#CardArea" id="CardArea4" x="54%" y="50%"/>
                        <use xlink:href="#CardArea" id="CardArea5" x="69%" y="46%"/>
                        <use xlink:href="#CardArea" id="CardArea6" x="81%" y="12%"/>
                        <use xlink:href="#CardArea" id="CardAreaDealer" x="47%" y="2%"/>

                        <!-- Plätze für Coins -->
                        <use xlink:href="#CoinArea" id="CoinArea1" x="15%" y="42%"/>
                        <use xlink:href="#CoinArea" id="CoinArea2" x="27%" y="76%"/>
                        <use xlink:href="#CoinArea" id="CoinArea3" x="42.5%" y="80%"/>
                        <use xlink:href="#CoinArea" id="CoinArea4" x="57.5%" y="80%"/>
                        <use xlink:href="#CoinArea" id="CoinArea5" x="73%" y="76%"/>
                        <use xlink:href="#CoinArea" id="CoinArea6" x="84%" y="42%"/>
                    </g>

                    <!-- create seats generically -->
                    <g id="PlayerNames">
                        <xsl:for-each select='game//player'>
                            <xsl:variable name='player_id' select='@player_id' />
                            <xsl:variable name='pos' select='$position//pos[@nr = $player_id]' />
                            <!-- show active player -->
                            <xsl:choose>
                                <xsl:when test= "./info/isActive = 'true'">
                                    <text id="PlayerName1" font-weight="bold" font-size="25" fill = "yellow" x="{$pos/nameArea/@x}%" y="{$pos/nameArea/@y}%">
                                        <xsl:value-of select='./info/username'/>
                                    </text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <text id="PlayerName1" font-weight="bold" font-size="25" x="{$pos/nameArea/@x}%" y="{$pos/nameArea/@y}%">
                                        <xsl:value-of select='./info/username'/>
                                    </text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </g>

                    <!-- show money  -->
                    <g id="PlayerMoney">
                        <xsl:for-each select='game//player'>
                            <xsl:variable name='player_id' select='@player_id' />
                            <text id="{concat('PlayerMoney', $player_id)}" x="{$position//pos[@nr = $player_id]/moneyArea/@x}%" y="{$position//pos[@nr = $player_id]/moneyArea/@y}%">
                                <xsl:value-of select='./info/money'/>
$
                            </text>
                        </xsl:for-each>
                    </g>

                    <!-- show HandValues -->
                    <g id="PlayerHandValue">
                        <xsl:for-each select='game//player'>
                            <xsl:variable name='player_id' select='@player_id' />
                            <text id="{concat('PlayerHandValue', $player_id)}" x="{3 + $position//pos[@nr = $player_id]/moneyArea/@x}%" y="{$position//pos[@nr = $player_id]/moneyArea/@y}%">
                               Hand: &#160;
                                <xsl:value-of select='./info/handValue'/>
                                
                            </text>
                        </xsl:for-each>
                    </g>
                    
                    <!-- show the cards -->

                    <g id="PlayerCards">
                        <xsl:for-each select='game//player'>
                            <xsl:variable name='player_id' select='@player_id' />
                            <xsl:for-each select='.//card' >

                                <use href="#cardShape" x="{($position//pos[@nr = $player_id]/cardShape/@x + (4 * (position()- 1))) * 2}%" y="{$position//pos[@nr = $player_id]/cardShape/@y}%" transform="scale(0.5)">
                                </use>

                                <use href="#{@color}" transform="scale(0.45)" height="100%" width="100%" x="{($position//pos[@nr = $player_id]/cardColor/@x + (4.4 * (position()- 1))) * 2}%" y="{$position//pos[@nr = $player_id]/cardColor/@y}%" />

                                <xsl:if test="@color='diamond' or @color='heart' ">

                                    <text color="red" fill="red" font-size="250%" transform="scale(0.5)" x="{($position//pos[@nr = $player_id]/cardValueTop/@x + (4 * (position()- 1))) * 2}%" y="{$position//pos[@nr = $player_id]/cardValueTop/@y}%">
                                        <xsl:value-of select="@name"/>
                                    </text>
                                    <text color="red" fill="red" font-size="250%" transform="scale(0.5)" x="{($position//pos[@nr = $player_id]/cardValueBottom/@x + (4 * (position()- 1))) * 2}%" y="{$position//pos[@nr = $player_id]/cardValueBottom/@y}%">
                                        <xsl:value-of select="@name"/>
                                    </text>

                                </xsl:if>

                                <xsl:if test="@color='club' or @color='spade' ">
                                    <text color="black" fill="black" font-size="250%" transform="scale(0.5)" x="{($position//pos[@nr = $player_id]/cardValueTop/@x + (4 * (position()- 1))) * 2}%" y="{$position//pos[@nr = $player_id]/cardValueTop/@y}%">
                                        <xsl:value-of select="@name"/>
                                    </text>

                                    <text color="black" fill="black" font-size="250%" transform="scale(0.5)" x="{($position//pos[@nr = $player_id]/cardValueBottom/@x + (4 * (position()- 1))) * 2}%" y="{$position//pos[@nr = $player_id]/cardValueBottom/@y}%">
                                        <xsl:value-of select="@name"/>
                                    </text>
                                </xsl:if>

                            </xsl:for-each>
                        </xsl:for-each>
                    </g>

                    <!-- player coins -->
                    <g id="PlayerCoins">
                        <xsl:for-each select='game//player'>
                            <xsl:variable name='player_id' select='@player_id' />
                            <xsl:variable name='pos' select='$position//pos[@nr = $player_id]' />
                            <xsl:for-each select=".//coin[@amount >= 1]">
                                <text>
                                    <xsl:value-of select='$pos/firstCoin/@x' />
                                </text>
                                <xsl:choose>
                                    <xsl:when test="@amount = 2">
                                        <use href="{concat('#coin','_',@value)}" transform="scale(0.5)" x="{($pos/firstCoin/@x + (3 * (position()- 1))) * 2}%" y="{$pos/firstCoin/@y}%" />
                                        <use href="{concat('#coin','_',@value)}" transform="scale(0.5)" x="{($pos/firstCoin/@x + (3 * (position()- 1))) * 2}%" y="{$pos/firstCoin/@y +10}%" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <use href="{concat('#coin','_',@value)}" transform="scale(0.5)" x="{($pos/firstCoin/@x + (3 * (position()- 1))) * 2}%" y="{$pos/firstCoin/@y}%" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:for-each>
                    </g>

                    <g id="coin_1">
                        <circle r="4%" fill="white" stroke="black" />
                        <circle r="3.5%" fill="white" stroke="pink" stroke-width="10" stroke-dasharray="1.2%,1.2%" />
                        <text fill="red" font-size="50" dominant-baseline="middle" text-anchor="middle">1</text>
                    </g>
                    <g id="coin_2">
                        <circle r="4%" fill="white" stroke="black" />
                        <circle r="3.5%" fill="white" stroke="purple" stroke-width="10" stroke-dasharray="1.2%,1.2%" />
                        <text fill="red" font-size="50" dominant-baseline="middle" text-anchor="middle">2</text>
                    </g>
                    <g id="coin_5">
                        <circle r="4%" fill="white" stroke="black" />
                        <circle r="3.5%" fill="white" stroke="yellow" stroke-width="10" stroke-dasharray="1.2%,1.2%" />
                        <text fill="red" font-size="50" dominant-baseline="middle" text-anchor="middle">5</text>
                    </g>
                    <g id="coin_10">
                        <circle r="4%" fill="white" stroke="black" />
                        <circle r="3.5%" fill="white" stroke="green" stroke-width="10" stroke-dasharray="1.2%,1.2%" />
                        <text fill="red" font-size="50" dominant-baseline="middle" text-anchor="middle">10</text>
                    </g>
                    <g id="coin_20">
                        <circle r="4%" fill="white" stroke="black" />
                        <circle r="3.5%" fill="white" stroke="red" stroke-width="10" stroke-dasharray="1.2%,1.2%" />
                        <text fill="red" font-size="50" dominant-baseline="middle" text-anchor="middle">20</text>
                    </g>
                    <g id="coin_50">
                        <circle r="4%" fill="white" stroke="black" />
                        <circle r="3.5%" fill="white" stroke="blue" stroke-width="10" stroke-dasharray="1.2%,1.2%" />
                        <text fill="red" font-size="50" dominant-baseline="middle" text-anchor="middle">50</text>
                    </g>
                    <g id="coin_100">
                        <circle r="4%" fill="white" stroke="black" />
                        <circle r="3.5%" fill="white" stroke="black" stroke-width="10" stroke-dasharray="1.2%,1.2%" />
                        <text fill="red" font-size="50" dominant-baseline="middle" text-anchor="middle">100</text>
                    </g>
                    <g id="coin_200">
                        <circle r="4%" fill="white" stroke="black" />
                        <circle r="3.5%" fill="white" stroke="lightsteelblue" stroke-width="10" stroke-dasharray="1.2%,1.2%" />
                        <text fill="red" font-size="50" dominant-baseline="middle" text-anchor="middle">200</text>
                    </g>
                    <g id="coin_500">
                        <circle r="4%" fill="white" stroke="black" />
                        <circle r="3.5%" fill="white" stroke="goldenrod" stroke-width="10" stroke-dasharray="1.2%,1.2%" />
                        <text fill="red" font-size="50" dominant-baseline="middle" text-anchor="middle">500</text>
                    </g>


                    <g id="DealerCards">
                        <xsl:for-each select="$dealer//card">
                            <xsl:choose>
                                <xsl:when test="@hidden=true">
                                    <use href="#empty_card" x="{(47 + (5 * (position()- 1))) * 2}%" y="3%" transform="scale(0.5)" />
                                </xsl:when>

                                <xsl:otherwise>
                                    <use href="#cardShape" x="{(47 + (5 * (position()- 1))) * 2}%" y="3.7%" transform="scale(0.5)"></use>
                                    <use href="#{@color}" x="{(52.1 + (5.5 * (position()- 1))) * 2}%" y="2%" transform="scale(0.45)"></use>

                                    <xsl:choose>
                                        <!-- 1. roter fall: Karo -->
                                        <xsl:when test="@color='diamond' or @color='heart'">
                                            <text color="red" fill="red" font-size="250%" x="{(47.5 + (5 * (position()- 1))) * 2}%" y="8%" transform="scale(0.5)">
                                                <xsl:value-of select="@name"/>
                                            </text>
                                            <text color="red" fill="red" font-size="250%" x="{(49.8 + (5 * (position()- 1))) * 2}%" y="26%" transform="scale(0.5)">
                                                <xsl:value-of select="@name"/>
                                            </text>
                                        </xsl:when>

                                        <!-- sonst:schwarz -->
                                        <xsl:otherwise>
                                            <text color="black" fill="black" font-size="250%" x="{(47.5 + (5 * (position()- 1))) * 2}%" y="8%" transform="scale(0.5)">
                                                <xsl:value-of select="@name"/>
                                            </text>
                                            <text color="black" fill="black" font-size="250%" x="{(49.8 + (5 * (position()- 1))) * 2}%" y="26%" transform="scale(0.5)">
                                                <xsl:value-of select="@name"/>
                                            </text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </g>

                    <g id="Bets">
                        <text id="PlayerName1" x="13%" y="42%">
                            <xsl:value-of select='$player1/info/bet'/>
                        </text>
                        <text id="PlayerName2" x="25%" y="76%">
                            <xsl:value-of select='$player2/info/bet'/>
                        </text>
                        <text id="PlayerName3" x="40%" y="88%">
                            <xsl:value-of select='$player3/info/bet'/>
                        </text>
                        <text id="PlayerName4" x="55%" y="88%">
                            <xsl:value-of select='$player4/info/bet'/>
                        </text>
                        <text id="PlayerName5" x="70%" y="76%">
                            <xsl:value-of select='$player5/info/bet'/>
                        </text>
                        <text id="PlayerName6" x="82%" y="42%">
                            <xsl:value-of select='$player6/info/bet'/>
                        </text>
                    </g>

                </defs>

                <!--zeigt Tisch -->
                <use xlink:href="#blankTable"/>

                <!-- zeigt Spielernamen -->
                <use xlink:href="#PlayerNames"/>

                <!-- zeigt Einsätze -->
                <use xlink:href = "#PlayerMoney"></use>
                
                <!-- zeigt HandValue -->
                <use xlink:href = "#PlayerHandValue"></use>

                <!-- displays cards -->
                <use xlink:href="#PlayerCards"/>
                <use xlink:href="#DealerCards"/>

                <!-- displays coins -->
                <use xlink:href="#PlayerCoins"/>

            </svg>

            <!-- ACTION BUTTONS -->
            <div class='actionButtons text-center' style='width:30%; position: fixed; bottom:0px'>
                <xsl:if test="game/gameInfo/state = 'waiting' ">
                    <h1 class='heartbeat'> Waiting for more Player to join </h1>

                    <xsl:if test='game/gameInfo/createdBy/userID = $userID' >
                        <form method='post' action='/xlink/game/{$gameID}/{$userID}/start'>
                            <button type='submit' class='btn btn-primary btn-block'> Start Game </button>
                        </form>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="$isActive = 'true' ">

                    <!-- Form for placing Bet-->
                    <xsl:if test="$state = 'betting' ">
                        <xsl:if test='game//player[./info/userID = $userID]/info/money > 0' >
                            <form method='post' action='/xlink/game/{$gameID}/{$userID}/placeBet'>
                                <xsl:variable name='maxBet' select='//player[info/userID = $userID]/info/money' />
                                <input class="form-control" type='number' name='bet_amount' placeholder='Your bet' min='1' max='{$maxBet}' required='' />
                                <button class='btn btn-primary btn-block heartbeat_slow' type='submit'> Place Bet! </button>
                            </form>
                        </xsl:if>
                        <xsl:if test='game//player[./info/userID = $userID]/info/money = 0' >
                            <form method='post'>
                                <button class='btn btn-primary btn-block heartbeat_slow' formaction='/xlink/leave/{$gameID}/{$userID}'> No Money. Leave Game now! </button>
                            </form>
                        </xsl:if>
                    </xsl:if>

                    <!-- Form for drawing initial Cards-->
                    <xsl:if test="$state = 'initialCards' ">
                        <form method='post' action='/xlink/game/{$gameID}/{$userID}/draw2Cards'>
                            <button class='btn btn-primary btn-block heartbeat_slow'> Draw 2 Cards </button>
                        </form>
                    </xsl:if>

                    <!-- Form for finishing Player-->
                    <xsl:if test="$state = 'finishingPlayer' ">
                        <form method='post'>
                            <!-- checking if the player has a BlackJack. If yes, he cannot draw another card -->
                            <xsl:if test=" game//player[./info/userID = $userID]/info/handValue &lt; 21">
                                <!--Double Down-->
                                <xsl:if test='count(game//player[./info/userID = $userID]//card) = 2'>
                                    <xsl:if test="game//player[./info/userID = $userID]/info/bet &lt; game//player[./info/userID = $userID]/info/money">
                                        <button class='btn btn-primary btn-block heartbeat_slow' formaction='/xlink/game/{$gameID}/{$userID}/turn/doubleDown'> Double Down </button>
                                    </xsl:if>
                                </xsl:if>

                                <!--Draw a Card-->

                                <button class='btn btn-primary btn-block heartbeat_slow' formaction='/xlink/game/{$gameID}/{$userID}/turn/hit'> Hit / Draw Card </button>
                            </xsl:if>
                            <!--Stand / next Player-->
                            <button class='btn btn-primary btn-block heartbeat_slow' formaction='/xlink/game/{$gameID}/{$userID}/turn/stand'> Stand / Next Player </button>
                        </form>
                    </xsl:if>
                </xsl:if>

                <!-- Pay Out and Be Ready for next Round-->
                <xsl:if test="$state = 'roundFinished' ">
                    <xsl:if test="//player[info/userID = $userID]/info/newInGame = 'false' and count(//player[info/userID = $userID]/cards//card) > 0 ">
                        <xsl:if test='//player[info/userID = $userID]/info/result = 2'>
                            <div>
                                <h1 class="text-center" style='font-weight: bold; color:green'>You Won!</h1>
                            </div>
                        </xsl:if>
                        <xsl:if test='//player[info/userID = $userID]/info/result = 1'>
                            <div>
                                <h1 class="text-center" style='font-weight: bold; color:yellow'>Tie!</h1>
                            </div>
                        </xsl:if>
                        <xsl:if test='//player[info/userID = $userID]/info/result = 0'>
                            <div >
                                <h1 class="text-center" style='font-weight: bold; color:red'>You Lost!</h1>
                            </div>
                        </xsl:if>


                        <!-- Form for next Round -->
                        <form method='post'>
                            <!--Pay Out and play next Round-->
                            <button class='btn btn-primary btn-block heartbeat_slow' formaction='/xlink/game/{$gameID}/{$userID}/nextRound'> Pay out and play next Round </button>

                            <!--Pay out and leave Game-->
                            <button class='btn btn-primary btn-block heartbeat_slow' formaction='/xlink/leave/{$gameID}/{$userID}'> Pay out and leave Game </button>
                        </form>
                    </xsl:if>
                    <xsl:if test="//player[info/userID = $userID]/info/newInGame = 'true' ">
                        <!-- Form for next Round -->
                        <form method='post'>
                            <!--Pay Out and play next Round-->
                            <button class='btn btn-primary btn-block heartbeat_slow' formaction='/xlink/game/{$gameID}/{$userID}/nextRound'> Play next Round </button>

                            <!--Pay out and leave Game-->
                            <button class='btn btn-primary btn-block heartbeat_slow' formaction='/xlink/leave/{$gameID}/{$userID}'> Leave Game </button>
                        </form>
                    </xsl:if>
                </xsl:if>

            </div>



            <!-- die Karten zum dynamischen zusammensetzens -->
            <!-- club -->
            <svg>
                <defs>
                    <svg id = "club">
                        <g>
                            <circle r="30" cx = "75" cy = "90" fill = "black"></circle>
                            <circle r = "30" cx = "55" cy = "120" fill = "black"></circle>
                            <circle r="30" cx = "95" cy = "120" fill = "black"></circle>
                            <polygon points = "75,135 55,180 95,180"></polygon>
                        </g>
                    </svg>

                    <svg id = "heart">
                        <g>
                            <circle cx="50" cy="90" r="27" style="fill:red;stroke:red"/>
                            <circle cx="100" cy="90" r="27" style="fill:red;stroke:red"/>
                            <polygon points="25,100 125,100 75,175" style="fill:red;stroke:red"/>
                        </g>
                    </svg>

                    <svg id = "diamond">
                        <g>
                            <polygon points="75,52 35,112 75,172 115,112 75,52" 
                            style="fill:red;stroke:black;stroke-width:0"/>
                        </g>
                    </svg>

                    <svg id ="spade">
                        <g>
                            <circle cx="55" cy="140" r="23" />
                            <circle cx="95" cy="140" r="23" />
                            <polygon points="75,55 35,130 115,130" />
                            <polygon points="75,135 55,180 95,180" />
                        </g>
                    </svg>

                    <!-- back of card -->
                    <g id="empty_card">
                        <rect width="150" height="240" fill = "url(#grad1)" stroke="black" stroke-width = "2.5" stroke-linejoin="round" rx="20" ry="20"></rect>
                        <defs>
                            <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">
                                <stop offset="0%" style="stop-color:rgb(255,255,0);stop-opacity:1" />
                                <stop offset="100%" style="stop-color:rgb(255,0,0);stop-opacity:1" />
                            </linearGradient>
                        </defs>
                    </g>
                    <!-- Card shape -->
                    <svg id = "cardShape">
                        <g>
                            <rect width="9%" height="25%" fill = "white" stroke="black" stroke-width = "2.5" stroke-linejoin="round" rx="20" ry="20"></rect>
                        </g>
                    </svg>
                </defs>
            </svg>
        </body>
    </xsl:template>
</xsl:stylesheet>