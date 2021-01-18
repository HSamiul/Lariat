//
//  Authentication.swift
//  LariatUI
//
//  Created by Samiul Hoque on 1/17/21.
//

import Foundation

func log(_ message: Any) {
    print("[\(Date())] \(message)")
}

var clientToken: String = "U2FtaXVsSG8tTGFyaWF0LVBSRC03ZDRhMmZlNjYtNGIwMTBkZDA6UFJELWQ0YTJmZTY2OGMzZS01ZmM3LTRhNmQtYTVjNi05MjZk"
var redirectURI: String = "Samiul_Hoque-SamiulHo-Lariat-vvdioralj"


protocol UserInfo {
    var consentToken: String { get }
    var userToken: String { get }
    var refreshToken: String { get }
}

struct User: UserInfo {
    var consentToken: String
    var userToken: String
    var refreshToken: String
}

protocol webRequest {
    associatedtype contentType
    
    var url: URL { get }
    var headers: [String: String]? { get }
    var payload: contentType { get }
    var request: URLRequest { get }
    
    mutating func sendRequest()
}

struct userTokenRequest: webRequest {
    var url: URL = URL(string: "https://api.ebay.com/identity/v1/oauth2/token")!
    
    var headers: [String: String]? = [
        "Authorization": "Basic \(clientToken)",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    var payload: URLComponents = URLComponents()
    var request: URLRequest
    
    var authToken: String?
    var userToken: String?
    var refreshToken: String?
    
    init(authToken: String) {
        self.authToken = authToken
        
        self.payload.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: authToken),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]
        
        self.request = URLRequest(url: self.url)
        self.request.httpMethod = "POST"
        self.request.allHTTPHeaderFields = self.headers
        self.request.httpBody = payload.query?.data(using: .utf8)
        
        log("Created UTR instance")
    }
    
    mutating func sendRequest() {
        var userToken: Any?
        var refreshToken: Any?
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                log(error?.localizedDescription ?? "No data received")
                return
            }
            
            DispatchQueue.main.async {
                let responseJSON = try? JSONSerialization.jsonObject(with: data)

                if let responseJSON = responseJSON as? [String: String] {
                    userToken = responseJSON["access_token"]
                    refreshToken = responseJSON["refresh_token"]
                }
                
                else { log("No response JSON received. Unsuccessfully requested user and request token.") }
            }
        }.resume()

        if let userToken = userToken { self.userToken = userToken as? String}
        if let refreshToken = refreshToken { self.refreshToken = refreshToken as? String }
        
        if let _ = userToken, refreshToken != nil {
            log("Successfully requested user and refresh token.")
        }
    }
}

var test = userTokenRequest(authToken: "v%5E1.1%23i%5E1%23I%5E3%23r%5E1%23f%5E0%23p%5E3%23t%5EUl41XzU6QTA3QjU5MDRCN0U3NzIwQURBOTEyNzU4QkZGMkU5QzJfMF8xI0VeMjYw")

//test.sendRequest()

