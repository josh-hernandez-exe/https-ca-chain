var fs = require('fs');
var https = require('https');
var constants = require('constants');
var config = JSON.parse(fs.readFileSync("config.json"));

serverSuffix=""
if (process.argv[2]) {
    var serverSuffix= process.argv[2];
}

var serverName="server"+serverSuffix;
var serverFolder=__dirname+"/server";

var serverKeyFile=[
    serverFolder,
    "private",
    serverName+".key.pem"
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


// var serverCertChainList = [
//     fs.readFileSync(serverCertFile),
//     fs.readFileSync(__dirname+"/"+config.intermediate.cert),
//     fs.readFileSync(__dirname+"/"+config.master.cert)
// ]


// var crlFile = __dirname + "/" + config.intermediate.crl;
var crlFile = __dirname + "/" + config.master.crl;

// var options = {
//     key: fs.readFileSync(serverKeyFile),
//     cert: fs.readFileSync(serverCertFile),
//     ca: fs.readFileSync(serverCertChainFile),
//     crl: fs.readFileSync(crlFile),
//     passphrase:"",
//     requestCert: true, 
//     rejectUnauthorized: true,
//     ciphers: [
//       "ECDHE-RSA-AES128-SHA256",
//       "DHE-RSA-AES128-SHA256",
//       "AES128-GCM-SHA256",
//       "!RC4",
//       "HIGH",
//       "!MD5",
//       "!aNULL"
//     ].join(":"),
//     honorCipherOrder: true,
//     secureProtocol: 'TLSv1_method'
// };


var options = {
    key: fs.readFileSync(serverKeyFile),
    cert: fs.readFileSync(serverCertFile),
    ca: fs.readFileSync(serverCertChainFile),
    crl: fs.readFileSync(crlFile),
    requestCert: true,
    rejectUnauthorized: true
};


https.globalAgent.options.ca = [];
// https.globalAgent.options.ca.push(fs.readFileSync(__dirname+"/"+config.intermediate.chain));
https.globalAgent.options.ca.push(fs.readFileSync(__dirname+"/"+config.master.cert));

https.createServer(options, function (req, res) {
    if (req.socket.authorized){ // shouldn't even get here if not authorized
        console.log([
            new Date(),
            req.connection.remoteAddress,
            req.socket.getPeerCertificate().subject.CN
        ].join("\t"));
        res.writeHead(200);
        res.end("hello world\n");
    } else {
        console.log("Rejected");
        // console.log(req.socket.getPeerCertificate());
    }
}).listen(config.port);

console.log('listening on 0.0.0.0:'+config.port);
