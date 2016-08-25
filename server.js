var fs = require('fs');
var https = require('https');
var constants = require('constants');

clientPrefix=""
if (process.argv[2]) {
    var clientPrefix= process.argv[2];
}

var serverName="server"+clientPrefix+"-key";
var serverFolder=__dirname+"/server";

var serverKeyFile=[
    serverFolder,
    "private",
    serverName+".pem"
].join("/");

var serverCertFile=[
    serverFolder,
    "certs",
    serverName+".cert.pem"
].join("/");

var serverCertChainFile=[
    serverFolder,
    "certs",
    serverName+".chain.cert.pem"
].join("/");

var crlFile = __dirname + "/intermediate/crl/intermediate.crl.pem";

var options = {
    key: fs.readFileSync(serverKeyFile),
    cert: fs.readFileSync(serverCertFile),
    ca: fs.readFileSync(serverCertChainFile),
    // crl: fs.readFileSync(crlFile),
    passphrase:"",
    requestCert: true, 
    rejectUnauthorized: true,
    ciphers: [
      "ECDHE-RSA-AES128-SHA256",
      "DHE-RSA-AES128-SHA256",
      "AES128-GCM-SHA256",
      "!RC4",
      "HIGH",
      "!MD5",
      "!aNULL"
    ].join(":"),
    honorCipherOrder: true,
    secureProtocol: 'TLSv1_method'
};

https.globalAgent.options.ca = [];
https.globalAgent.options.ca.push(fs.readFileSync(__dirname+"/intermediate/certs/ca-chain.cert.pem"));


https.createServer(options, function (req, res) {
    if (req.socket.authorized){ // shouldn't even get here if not authorized
        console.log([
            new Date(),
            req.connection.remoteAddress,
            req.socket.getPeerCertificate().subject.CN
        ].join("\t"))
        res.writeHead(200);
        res.end("hello world\n");
    } else {
        console.log("Rejected")
    }
}).listen(4433);

console.log('listening on 0.0.0.0:4433');
