# backfire - use self-signed certificate

Xcode 7 playground for iOS showing how to use self-signed certificates. Find the relevant Apple technote [here](https://developer.apple.com/library/ios/technotes/tn2232/_index.html).

Create self signed X.509 certificate:
```
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout key.pem -out cert.pem \
    -subj "/C=US/ST=CA/O=Swift/OU=example/CN=localhost"
```

Copy to DER encoded certificate for the client-side:
```
$ openssl x509 -in cert.pem -out cert.der -outform DER
```

Start https server:
```
$ node server.js &
```

Open the playground and add `./cert.der` to its `Resources`.
Execute playground.

Problems? Check the server:
```
$ openssl s_client -connect localhost:8081
```

## License

[MIT License](https://raw.github.com/michaelnisi/backfire/master/LICENSE)
