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

    static func callPost(url: URL, payload: String, method:String="POST", credentials: String="", finish: @escaping ((message: String, data: Data?)) -> Void) {
        var request = URLRequest(url: url)
        if credentials != "" {
            request.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = method

        let postString = payload
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

    static func infoForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
}
