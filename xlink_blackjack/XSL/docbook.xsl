<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <xsl:template match="/">
        <xsl:param name='userID' />
        <div>
        <form class='form'  method='get'>
            <button  type='submit' formaction='/xlink/lobby/{$userID}' class="btn btn-secondary btn-lg btn-block"> Go to the Lobby </button>
        </form>
        <object width="100%" height="100%" type="application/pdf" data="/static/xlink_blackjack/docbook.pdf">
            <!--Error message if the PDF cannot be displayed -->
            <p>Unfortunately, the DocBook couldn't be loaded</p>
        </object>
        </div>
    </xsl:template>
    
</xsl:stylesheet>