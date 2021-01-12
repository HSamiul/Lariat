import Foundation
import SwiftUI

class Request {

    let url: URL
    var method: String

    var request: URLRequest

    init(url: String, method: String = "GET") {

        self.url = URL(string: url)!
        self.method = method
        self.request = URLRequest(url: self.url)

        self.request.httpMethod = self.method
    }

    func sendRequest() -> Void {

        let semaphore = DispatchSemaphore.init(value: 0) // semaphore makes sure task fully executes
        let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
            
            defer { semaphore.signal() }
            
            let log = """
            Method: \(self.request.httpMethod ?? "Default method used in request, \"GET\"")
            Headers: \(self.request.allHTTPHeaderFields?.description ?? "No headers specified")
            """
            print(log)
            print("Response JSON:\n")

            guard let data = data, error == nil else { // if data doesn't exist and error isn't nil...
                print(error?.localizedDescription ?? "No data about the error was provided.")
                return
            }

            // try? makes sure that if .jsonObject() doesn't return its expected value, nil is returned instead
            let response = try? JSONSerialization.jsonObject(with: data, options: [])
            // as? makes sure that if responseJSON isn't a [String: Any] type, nothing happens
            if let response = response as? [String: Any] { print("\(response)\n\n") }
            else { print("Either no response JSON was received or it could not be processed without error")}
            
        }

        task.resume()
        semaphore.wait()
    }
}

class ClientOAuth: Request {

    let clientKey: String
    let contentType = "application/x-www-form-urlencoded"
    let grantType = "client_credentials"
    let scope = "https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope"
    
    //  lazy makes it so requesetHeaders is only created when "requested", like doing myObject.requestHeaders
    //  w/o lazy an error is thrown because you can't use properties of an object (clientKey, contentType) before the object exists (is initialized)
    lazy var requestHeaders: [String: String] = [
        "Authorization": "Basic \(clientKey)",
        "Content-Type": contentType
    ]

    //URLComponents is a structure that takes in URL components and constructs a URL
    lazy var bodyParameters = URLComponents()

    init(clientKey: String) {
        
        //  assume clientKey already in B64Encode(clientID:clientSecret) form
        self.clientKey = clientKey
        super.init(url: "https://api.ebay.com/identity/v1/oauth2/token", method: "POST")

        bodyParameters.queryItems = [
            URLQueryItem(name: "grant_type", value: grantType),
            URLQueryItem(name: "scope", value: scope)
        ]

        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = bodyParameters.query?.data(using: .utf8)
        //print("Payload: \(bodyParameters.description)") // for logging purposes
    }
}


class UserOAuth: Request {
    let clientKey: String
    let consentKey: String
    let redirectURI: String

    let contentType = "application/x-www-form-urlencoded"
    let grantType = "authorization_code"

    lazy var requestHeaders: [String: String] = [
        "Authorization": "Basic \(clientKey)",
        "Content-Type": contentType
    ]


    var userToken: String?
    var refreshToken: String?

    init(clientKey: String, consentKey: String, redirectURI: String) {
        
        //  assume clientKey already in B64Encode(clientID:clientSecret) form
        self.clientKey = clientKey
        self.consentKey = consentKey
        self.redirectURI = redirectURI

        super.init(url: "https://api.ebay.com/identity/v1/oauth2/token", method: "POST")



        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        //print("Payload: \(bodyParameters.description)") // for logging purposes
    }

        func requestUserToken() -> Void {
            var userToken: Any?
            var refreshToken: Any?

            var bodyParameters = URLComponents()
            bodyParameters.queryItems = [
                URLQueryItem(name: "grant_type", value: grantType),
                URLQueryItem(name: "code", value: consentKey),
                URLQueryItem(name: "redirect_uri", value: redirectURI)
            ]
            self.request.httpBody = bodyParameters.query?.data(using: .utf8)

            let semaphore = DispatchSemaphore.init(value: 0) // semaphore makes sure task fully executes
            let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
                
                defer { semaphore.signal() }
                
                let log = """
                Method: \(self.request.httpMethod ?? "Default method used in request, \"GET\"")
                Headers: \(self.request.allHTTPHeaderFields?.description ?? "No headers specified")
                Payload: \(bodyParameters.description)
                """
                print(log)
                print("Response JSON:\n")

                guard let data = data, error == nil else { // if data doesn't exist and error isn't nil...
                    print(error?.localizedDescription ?? "No data about the error was provided.")
                    return
                }

                // try? makes sure that if .jsonObject() doesn't return its expected value, nil is returned instead
                let response = try? JSONSerialization.jsonObject(with: data, options: [])
                // as? makes sure that if responseJSON isn't a [String: Any] type, nothing happens
                if let response = response as? [String: Any] { 
                    print("\(response)\n\n") 
                    userToken = response["access_token"]
                    refreshToken = response["refresh_token"]
                }
                else { print("Either no response JSON was received or it could not be processed without error")}
                
            }

            task.resume()
            semaphore.wait()

            // this userToken is not the same as userToken property, it exists solely in the scope of the line below
            if let userToken = userToken { self.userToken = String(describing: userToken) }
            if let refreshToken = refreshToken { self.refreshToken = String(describing: refreshToken) } 
    }
    
    func refreshUserToken() -> Void {

        var userToken: Any?
        var bodyParameters = URLComponents()
        bodyParameters.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: self.refreshToken),
            URLQueryItem(name: "scope", value: "https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope")
        ]
        self.request.httpBody = bodyParameters.query?.data(using: .utf8)

        let semaphore = DispatchSemaphore.init(value: 0) // semaphore makes sure task fully executes
        let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
            
            defer { semaphore.signal() }
            
            let log = """
            Method: \(self.request.httpMethod ?? "Default method used in request, \"GET\"")
            Headers: \(self.request.allHTTPHeaderFields?.description ?? "No headers specified")
            """
            print(log)
            print("Response JSON:\n")

            guard let data = data, error == nil else { // if data doesn't exist and error isn't nil...
                print(error?.localizedDescription ?? "No data about the error was provided.")
                return
            }

            // try? makes sure that if .jsonObject() doesn't return its expected value, nil is returned instead
            let response = try? JSONSerialization.jsonObject(with: data, options: [])
            // as? makes sure that if responseJSON isn't a [String: Any] type, nothing happens
            if let response = response as? [String: Any] { 
                print("\(response)\n\n") 
                userToken = response["access_token"]
            }
            else { print("Either no response JSON was received or it could not be processed without error")}
            
        }

        task.resume()
        semaphore.wait()

        if let userToken = userToken { self.userToken = String(describing: userToken) }
    }
}

//  Optional test code

//let request1 = Request(url: "http://httpbin.org/get", method: "GET")
//request1.sendRequest()

//let request2 = ClientOAuth(clientKey: "U2FtaXVsSG8tTGFyaWF0LVBSRC03ZDRhMmZlNjYtNGIwMTBkZDA6UFJELWQ0YTJmZTY2OGMzZS01ZmM3LTRhNmQtYTVjNi05MjZk")
//request2.sendRequest()

//let request3 = UserOAuth(clientKey: "U2FtaXVsSG8tTGFyaWF0LVBSRC03ZDRhMmZlNjYtNGIwMTBkZDA6UFJELWQ0YTJmZTY2OGMzZS01ZmM3LTRhNmQtYTVjNi05MjZk", consentKey: "v%5E1.1%23i%5E1%23r%5E1%23p%5E3%23I%5E3%23f%5E0%23t%5EUl41Xzc6NjE2NTNFOUJENUYwN0Q3NjlCRjkyMDBGQkE3RUMzNTlfMl8xI0VeMjYw", redirectURI: "Samiul_Hoque-SamiulHo-Lariat-vvdioralj")
//request3.requestUserToken()
//request3.refreshUserToken()
