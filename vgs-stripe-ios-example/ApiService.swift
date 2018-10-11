//
// Created by andrew.slepakurov on 10/9/18.
// Copyright (c) 2018 Very Good Security. All rights reserved.
//

import Foundation

class ApiService {
    static func getPostString(params: [String: Any]) -> String {
        var data = [String]()
        for (key, value) in params {
            data.append(key + "=\(value)")
        }
        return data.map {
            String($0)
        }.joined(separator: "&")
    }

    static func callPost(url: URL, params: [String: Any], method:String="POST", credentials: String, finish: @escaping ((message: String, data: Data?)) -> Void) {
        var request = URLRequest(url: url)
        if credentials != "" {
            request.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = method

        let postString = self.getPostString(params: params)
        request.httpBody = postString.data(using: .utf8)

        var result: (message: String, data: Data?) = (message: "Fail", data: nil)
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { data, response, error in
            if (error != nil) {
                result.message = "Fail Error not null : \(error.debugDescription)"
            } else {
                result.message = "Success"
                result.data = data
            }
            finish(result)
        }
        task.resume()
    }

    static func callPostWithProxy(url: URL, params: [String: Any], method:String="POST", credentials: String, finish: @escaping ((message: String, data: Data?)) -> Void) {
        let proxyUser = infoForKey("PROXY_USER")!
        let proxyPass = infoForKey("PROXY_PASS")!
        let tenantUrl = infoForKey("PROXY_URL")!
        let userPass = "\(proxyUser):\(proxyPass)"
        let credentialData = "\(userPass)".data(using: String.Encoding.utf8)!
        let base64Cred = credentialData.base64EncodedString(options: [])
        let proxyDict : [AnyHashable: Any] = ["HTTPSEnable": Int(1), "HTTPSProxy": tenantUrl, "HTTPSPort": 8080]
        let header: [AnyHashable: Any] = ["Proxy-Authorization": "Basic \(base64Cred)"]
        let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.connectionProxyDictionary = proxyDict
        sessionConfiguration.httpAdditionalHeaders = header

        var request = URLRequest(url: url)
        if credentials != "" {
            request.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = method
        let postString = self.getPostString(params: params)
        request.httpBody = postString.data(using: .utf8)

        
        var result: (message: String, data: Data?) = (message: "Fail", data: nil)
        let task = URLSession(configuration: sessionConfiguration, delegate: SessionDelegate(), delegateQueue: nil).dataTask(with: request) { data, response, error in
            if (error != nil) {
                result.message = "Fail Error not null : \(error.debugDescription)"
            } else {
                result.message = "Success"
                result.data = data
            }
            finish(result)
        }
        task.resume()
    }

    static func infoForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
}
