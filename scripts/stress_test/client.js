// client

var net = require('net');
var path = require('path');
var fs = require('fs');

var watchDir = path.resolve(__dirname, './tmp');
var port = 8124;

var client = net.connect({port: port}, function() { //'connect' listener
  console.log('client connected');
  client.write('world!\r\n');
});
client.on('data', function(data) {
  console.log(data.toString());
  // client.end();
});
client.on('end', function() {
  console.log('client disconnected');
});

var filename = path.join(watchDir, 'test');
fs.writeFile(filename, 'TEST TEST TEST');

setTimeout(function(){
  fs.unlinkSync(filename);
}, 1000);

/*
// todo

in node container
1. watch directory
2. watchFile "test"
3. send filename and notification stats via socket server on file/dir change

in host
1. in samba dir, write file "test"
2. check for correct change notification on socket server
3. write random files and dirs to samba dir
4. check for changes on socket server

vary time delay between writing files
change multiple files at once
*/
