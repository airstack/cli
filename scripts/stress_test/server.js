// server

var net = require('net');
var path = require('path');
var fs = require('fs');

var watchDir = path.resolve(__dirname, './tmp');
var port = 8124;

var server = net.createServer(function(c) { //'connection' listener
  console.log('server connected');
  c.on('end', function() {
    console.log('server disconnected');
  });
  fs.watch(watchDir, function(event, filename) {
    c.write(filename + ': ' + event + '\r\n');
    // todo: send fs.stat results of filename
  });

  c.write('Hello\r\n');
  c.pipe(c);
});

server.listen(port, function() { //'listening' listener
  console.log('server bound');
});
