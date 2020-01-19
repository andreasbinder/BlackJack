<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <xsl:template match='/'>
        <div style="max-width:80%; margin:auto;">
            <xsl:param name='userID' />
            <xsl:param name='username' />
            <xsl:param name='userCountLobby' />
            <xsl:param name='userCountGame' />
            <h1 style="
                font-weight: bold;
                color: white;
                border-bottom: white 6px solid;
                padding-bottom: 10px;
                margin: 20px 0px 0px  0px;
            ">
                Welcome &#160;<xsl:value-of select='$username' />!
            </h1>
            <h5 style="
                font-weight: bold;
                color: white;
                margin: 5px 0px 40px  0px;
            ">
                <xsl:value-of select='$userCountLobby - 1' /> &#160;other user are currently in the Lobby,&#160;<xsl:value-of select='$userCountGame' />&#160;user are playing a Game
            </h5>
        
            <form class='form'  method='get'>
                <button  type='submit' formaction='/xlink/newGame/{$userID}' class="btn btn-primary btn-lg btn-block"> Create new Game </button>
                <button  type='submit' formaction='/xlink/lobby/leaderboard/{$userID}' class="btn btn-secondary btn-lg btn-block"> View the Leaderboard </button>
                <button  type='submit' formaction='/xlink/lobby/docbook/{$userID}' class="btn btn-secondary btn-lg btn-block"> View the DocBook </button>
                
            </form>


            <div  style='background-color: ghostwhite; margin-top: 40px;'>
                    <table class='table table-hover'>
                        <thead class='thead-dark'>
                            <tr>
                            <th >Game</th>
                            <th >Player - Score</th>
                            <th class='text-center'>Capacity</th>
                            <th class='text-center'>Join</th>
                            <th class='text-center'>Delete</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select='//game'>
                                <xsl:variable name='gameID' select='@id' />
                                <xsl:variable name='players' select='./gameInfo/numPlayers' />
                                <xsl:variable name='activePlayers' select='./gameInfo/numActivePlayers' />
                                <tr>
                                    <td style='vertical-align:middle;'>
                                        <h6><xsl:value-of select='@id' /></h6>
                                        <br/>
                                        <h6>Created by: &#160; <xsl:value-of select='./gameInfo/createdBy/username' /></h6>
                                    </td>
                                    <td  style='vertical-align:middle;'>

                                        <table class='table-borderless table-no-hover'>
                                            <xsl:for-each select='./players//player'>
                                                <tr>
                                                    <td style='padding: 5px 8px'><xsl:value-of select='info/username' /></td>
                                                    <td style='padding: 5px 8px'><xsl:value-of select='info/score' /></td>
                                                </tr>
                                            </xsl:for-each>
                                        </table>
                                    </td >
                                    <td class='text-center' style='vertical-align:middle;'>
                                        <xsl:value-of select='$activePlayers' />/<xsl:value-of select='$players' />
                                    </td>
                                    <td style='vertical-align:middle;'>
                                        <form method='get' style='margin: 0px;'>
                                            <xsl:if test='$activePlayers = $players'>
                                                <button disabled='' type='submit' formaction='/xlink/lobby/{$userID}' class="btn btn-outline-danger btn-block"> Full </button>
                                            </xsl:if>
                                            <xsl:if test='$activePlayers != $players'>
                                                <button type='submit' formaction='/xlink/join/{$gameID}/{$userID}' class="btn btn-outline-success btn-block"> Join Game </button>
                                            </xsl:if>                                        
                                        </form>
                                    </td>
                                    <td style='vertical-align:middle;'>
                                        <div class='row'>
                                            <div class='col-sm'>
                                                <form method='get' style='margin: 0px;'>
                                                    <xsl:if test='./gameInfo/createdBy/userID = $userID'>
                                                        <button type='submit' formaction='/lobby/{$userID}/delete/{$gameID}' class='btn btn-block btn-outline-danger' > Delete Game </button>
                                                    </xsl:if>
                                                    <xsl:if test='./gameInfo/createdBy/userID != $userID'>
                                                        <button disabled='' type='submit' formaction='/lobby/{$userID}/delete/{$gameID}' class='btn btn-block btn-outline-danger' > Delete Game </button>
                                                    </xsl:if>
                                                </form>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>