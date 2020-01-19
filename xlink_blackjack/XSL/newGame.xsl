<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
  <xsl:template match="/">

    <xsl:param name='userID' />

    <div style="max-width:80%; margin:0 auto;">

      <h1 style="
        font-weight: bold;
        color: white;
        border-bottom: white 6px solid;
        padding-bottom: 10px;
        margin: 20px 0px 40px  0px;
      ">
        Create New Game
      </h1>


      <div style='margin-top: 50px;'>
        <form class='form'  method='get'>
                <button  type='submit' formaction='/xlink/lobby/{$userID}' class="btn btn-primary btn-lg btn-block"> Go back to Lobby </button>
            </form>

        <form method='post' action='/xlink/newGame/{$userID}' enctype="application/x-www-form-urlencoded">
          <!-- Infos about game -->
          <div class='form-row'>
            <div class='form-group col-md-6'>
              <label for='gameName' style='font-size: 1.75rem; color: white;'> Give your Game a Name </label>
              <input type='text' class="form-control" id='gameName' name='gameName' placeholder='optional' />
              <small class="form-text" style='font-size: 1.0rem; color: white'> default: new_game_timestamp</small>
            </div>
          </div>  
          <div class='form-row'>
            <div class='form-group col-md-6'>
              <label for='numStacks' style='font-size: 1.75rem; color: white;'> How many Card Stacks?</label>

              <input type='number' list='stacks' class="form-control" name='numStacks' placeholder='optional' min="1" max = '50' step="1"/>
              <small class="form-text" style='font-size: 1.0rem; color: white'> default: 5</small>

            </div>
          </div>

          <div class='form-row'>
            <div class='form-group col-md-6'>
              <label for='numPlayers' style='font-size: 1.75rem; color: white;'> How many Players?</label>
              <input type='number' list='stacks' class="form-control" name='numPlayers' placeholder='optional' min="1" step="1" max='6'/>
              <small class="form-text" style='font-size: 1.0rem; color: white'> default: 6</small>
            </div>
          </div>

          <button type='submit' class='btn btn-success btn-block'> Start your new Game! </button>

        </form>
      </div>
    </div>
  </xsl:template>
</xsl:stylesheet>
