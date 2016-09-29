var fs = require('fs');
var https = require('https');
var constants = require('constants');
var config = JSON.parse(fs.readFileSync("config.json"));

clientPrefix=""
if (process.argv[2]) {
    var clientPrefix= process.argv[2];
}

var clientName="client"+clientPrefix;
var clientFolder=__dirname+"/client";

var clientKeyFile=[
    clientFolder,
    "private",
    clientName+".key.pem"
].join("/");

var clientCertFile=[
    clientFolder,
    "certs",
    clientName+".cert.pem"
].join("/");

var clientCertChainFile=[
    clientFolder,
    "certs",
    clientName+".chain.cert.pem"
].join("/");

// var options = {
//     hostname: 'localhost',
//     port: config.port,
//     path: '/',
//     method: 'GET',
//     key: fs.readFileSync(clientKeyFile),
//     cert: fs.readFileSync(clientCertFile),
//     ca: fs.readFileSync(clientCertFile),
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
//     secureProtocol: 'TLSv1_method',
//     secureOptions: constants.SSL_OP_NO_SSLv3 | constants.SSL_OP_NO_SSLv2
// };

var options = {
    hostname: config.hostname,
    port: config.port,
    path: '/',
    method: 'GET',
    key: fs.readFileSync(clientKeyFile),
    cert: fs.readFileSync(clientCertFile),
    ca: fs.readFileSync(clientCertFile),
    };


https.globalAgent.options.ca = [];
https.globalAgent.options.ca.push(fs.readFileSync(__dirname+"/"+config.intermediate.chain));
// https.globalAgent.options.ca.push(fs.readFileSync(__dirname+"/"+config.master.cert));

var req = https.request(options, function(res) {
    res.on('data', function(data) {
        process.stdout.write(data);
    });
});

req.end();

req.on('error', function(e) {
    console.error(e);
});
