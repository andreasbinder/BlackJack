<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <xsl:template match='/'>
        <div style="max-width:80%; margin:auto;">
            <xsl:param name='userID' />

            <h1 style="
                font-weight: bold;
                color: white;
                border-bottom: white 6px solid;
                padding-bottom: 10px;
                margin: 20px 0px 40px  0px;
            ">
                | Leaderboard |
            </h1>
            <form class='form'  method='get'>
                <button  type='submit' formaction='/xlink/newGame/{$userID}' class="btn btn-primary btn-lg btn-block"> Create new Game </button>
                <button  type='submit' formaction='/xlink/lobby/{$userID}' class="btn btn-secondary btn-lg btn-block"> Go to the Lobby </button>
                <button  type='submit' formaction='/xlink/lobby/docbook/{$userID}' class="btn btn-secondary btn-lg btn-block"> View the DocBook </button>
            </form>

            <div  style='background-color: ghostwhite; margin-top: 40px;'>
                <table class='table table-hover'>
                    <thead class='thead-dark'>
                        <tr>
                        <th>Name</th>
                        <th>Played Games</th>
                        <th>Score</th>
                        <th>Highscore</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select='//user'>
                            <xsl:sort select='score' order='descending' />
                            <xsl:if test='@userID = $userID'>
                                <tr class="table-info">
                                    <td style='vertical-align:middle;'><xsl:value-of select='username' /></td>
                                    <td style='vertical-align:middle;'><xsl:value-of select='gamesPlayed' /></td>
                                    <td style='vertical-align:middle;'><xsl:value-of select='score' /></td>
                                    <td style='vertical-align:middle;'><xsl:value-of select='highscore' /></td>
                                </tr>
                            </xsl:if>
                            <xsl:if test='@userID != $userID'>
                                <tr>
                                    <td style='vertical-align:middle;'><xsl:value-of select='username' /></td>
                                    <td style='vertical-align:middle;'><xsl:value-of select='gamesPlayed' /></td>
                                    <td style='vertical-align:middle;'><xsl:value-of select='score' /></td>
                                    <td style='vertical-align:middle;'><xsl:value-of select='highscore' /></td>
                                </tr>
                            </xsl:if>
                        </xsl:for-each>
                    </tbody>
                </table>
            </div>    
        </div>
    </xsl:template>
</xsl:stylesheet>