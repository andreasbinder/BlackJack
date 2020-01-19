INSTALLATION

1. Download the basex-stomp version from here: https://github.com/BaseXdb/basex/tree/stomp
2. Unzip the folder
3. Navigate to basex-api/src/main
4. Place the "xlink_blackjack" and "static" folder inside the webapp folder
5. Navigate back to the basex-stomp root folder and run "mvn install -DskipTests"
6. Navigate to the basex-api folder and run "mvn jetty:run"
7. In your browser, open "localhost:8984/xlink/setup" to setup the basex database
8. In your browser, navigate to "localhost:8984/xlink" to login or register
9. Have fun!

RUN APPLICATION

1. After installation is finished run "mvn jetty:run" in basex-api folder
2. Go to http://localhost:8984/xlink
3. If newly installed, go to http://localhost:8984/xlink/setup in order to init the database


DOCBOOK
1. You can find the raw documentation docBook in the folder "./xlink_blackjack/XLink DocBook.xml"
