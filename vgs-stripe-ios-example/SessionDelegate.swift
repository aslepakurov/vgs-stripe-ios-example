//
// Created by andrew.slepakurov on 10/11/18.
// Copyright (c) 2018 Very Good Security. All rights reserved.
//

import Foundation

class SessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard
                challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                let serverTrust = challenge.protectionSpace.serverTrust,
                SecTrustEvaluate(serverTrust, nil) == errSecSuccess,
                let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {

            reject(with: completionHandler)
            return
        }

        let serverCertData = SecCertificateCopyData(serverCert) as Data

        let localCertPath = Bundle.main.path(forResource: "cert", ofType: "cer")!
        let localCertData = NSData(contentsOfFile: localCertPath) as Data?

        accept(with: serverTrust, completionHandler)

    }

    func reject(with completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    func accept(with serverTrust: SecTrust, _ completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
