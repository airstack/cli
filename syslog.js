// Usage: sudo node syslog.js

// works with sudo ...
// var dockerIP = '0.0.0.0';
var dockerIP = '192.168.59.3'; // vbox net

// does not work ...
// var dockerIP = '192.168.59.103'; // boot2docker ip

var port = 514;

var syslogParser = require('glossy').Parse; // or wherever your glossy libs are
var dgram  = require("dgram");
var socket = dgram.createSocket("udp4");

socket.on("message", function(rawMessage) {
    syslogParser.parse(rawMessage.toString('utf8', 0), function(parsedMessage){
        console.log(parsedMessage.host + ' - ' + parsedMessage.message);
    });
});

socket.on("listening", function() {
    var address = socket.address();
    console.log("Server now listening at " +
        address.address + ":" + address.port);
});

// ports < 1024 need suid
socket.bind(port, dockerIP, function() {
  console.log('bound');
});