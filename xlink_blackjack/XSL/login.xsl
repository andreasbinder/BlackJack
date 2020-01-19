<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <div class='container'>
        <div class='row text-white' style='margin-top: 10%'>
            <div class='col-md-6 offset-md-3 text-center'>
                <h1 style='border-bottom: solid black 2px'>Login</h1>
                <form role='form' method='post' action='/xlink/login' enctype="application/x-www-form-urlencoded">
                    
                    <div class="form-group">
                        <label for='username'> Username </label>
                        <input class="form-control" name='username' type='text' id='username'/>
                    </div>

                    <div class="form-group">
                        <label for='password'> Password </label>
                        <input class="form-control" name='password' type='text' id='password'/>
                    </div>
                    <button type='submit' class='btn btn-success btn-block'> Login </button>
                </form>
            </div>
        </div>

        <div class='row text-white' style='margin-top: 10%'>
            <div class='col-md-6 offset-md-3 text-center'>
                <h1 style='border-bottom: solid black 2px'>Register</h1>
                <form role='form' method='post' action='/xlink/register' enctype="application/x-www-form-urlencoded">
                    
                    <div class="form-group">
                        <label for='username'> Username </label>
                        <input class="form-control" name='username' type='text' id='username'/>
                    </div>

                    <div class="form-group">
                        <label for='password'> Password </label>
                        <input class="form-control" name='password' type='text' id='password'/>
                    </div>
                    <button type='submit' class='btn btn-success btn-block'> Register </button>
                </form>
            </div>
        </div>

    </div>

</xsl:stylesheet>