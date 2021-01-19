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

let group = DispatchGroup()

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
    
    init(_ authToken: String) {
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
        let semaphore = DispatchSemaphore.init(value: 0)
        
        var userToken: Any?
        var refreshToken: Any?
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }

            guard let data = data, error == nil else {
                log(error?.localizedDescription ?? "No data received")
                return
            }
            
            let responseJSON = (try? JSONSerialization.jsonObject(with: data)) as! [String: Any]
            

            if let _ = responseJSON["access_token"] {
                userToken = responseJSON["access_token"]
                refreshToken = responseJSON["refresh_token"]
                }
            else { log(responseJSON) }
    
        }.resume()
        semaphore.wait()

        semaphore.signal()
        if let userToken = userToken { self.userToken = userToken as? String }
        if let refreshToken = refreshToken { self.refreshToken = refreshToken as? String }
        
        if let _ = userToken, refreshToken != nil {
            log("Successfully requested and stored user and refresh token.")
        }
        semaphore.wait()
    }
}

//  Test code
//var URT = userTokenRequest("consentToken")
//URT.sendRequest()
