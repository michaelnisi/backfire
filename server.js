var auth = require('basic-auth')
var fs = require('fs')
var https = require('https')

var opts = {
  cert: fs.readFileSync('./cert.pem'),
  key: fs.readFileSync('./key.pem')
}

https.createServer(opts, function (req, res) {
  var credentials = auth(req)
  if (!credentials ||
      credentials.name !== 'Aladdin' ||
      credentials.pass !== 'open sesame') {
    res.statusCode = 401
    res.setHeader('WWW-Authenticate', 'Basic realm="example"')
    res.end('Access denied')
  } else {
    res.end('Access granted')
  }
}).listen(8081)
