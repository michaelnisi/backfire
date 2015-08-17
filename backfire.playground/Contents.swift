import Foundation

public class Certify: NSObject {
  let certs: [SecCertificate]
  init (cert: SecCertificate) {
    self.certs = [cert]
  }
}

extension Certify: NSURLSessionDelegate {
  public func URLSession(
    session: NSURLSession,
    didReceiveChallenge challenge: NSURLAuthenticationChallenge,
    completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
      let space = challenge.protectionSpace
      guard let trust = space.serverTrust else {
        print("no server trust in protection space")
        completionHandler(.CancelAuthenticationChallenge, nil)
        return
      }
      let status = SecTrustSetAnchorCertificates(trust, certs)
      if status == 0 {
        print("performing basic access authentication")
        completionHandler(.PerformDefaultHandling, nil)
      } else {
        print("canceling: \(status)")
        completionHandler(.CancelAuthenticationChallenge, nil)
      }
  }
}

func loadCert (name: String) -> SecCertificate? {
  let bundle = NSBundle.mainBundle()
  if let path = bundle.pathForResource("cert", ofType: "der") {
    if let data = NSData(contentsOfFile: path) {
      return SecCertificateCreateWithData(nil, data)
    }
  }
  return nil
}

func headers () -> [NSObject: String] {
  return ["Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="]
}

func createSession () -> NSURLSession? {
  let conf = NSURLSessionConfiguration.defaultSessionConfiguration()
  guard let cert = loadCert("cert.der") else {
    return nil
  }
  conf.HTTPAdditionalHeaders = headers()
  let del = Certify(cert: cert)
  let queue = NSOperationQueue()
  let sess = NSURLSession(configuration: conf, delegate: del, delegateQueue: queue)
  return sess
}

let session = createSession()
let sema = dispatch_semaphore_create(0)

func describe (er: NSError?) -> String? {
  return er?.userInfo["NSLocalizedDescription"] as? String
}

func stringWithData (data: NSData) -> NSString? {
  return data.length < 1 ? NSString(string: "not ok")
    : NSString(data: data, encoding: NSUTF8StringEncoding)
}

func request (uri: String) -> Bool {
  guard let sess = session else {
    return false
  }
  guard let url = NSURL(string: uri) else {
    return false
  }
  let task = sess.dataTaskWithURL(url) { data, response, error in
    if let er = error {
      let desc = describe(er)
      print(desc)
    }
    if let d = data {
      print("\(uri) - \(stringWithData(d))")
    }
    dispatch_semaphore_signal(sema)
  }
  task.resume()
  return dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER) == 0
}

request("https://localhost:8081")
