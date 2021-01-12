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
            else { print("Either no response JSON was sent or it could not be processed without error")}
            
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

//  Optional test code

let request1 = Request(url: "http://httpbin.org/get", method: "GET")
request1.sendRequest()

let request2 = ClientOAuth(clientKey: "U2FtaXVsSG8tTGFyaWF0LVBSRC03ZDRhMmZlNjYtNGIwMTBkZDA6UFJELWQ0YTJmZTY2OGMzZS01ZmM3LTRhNmQtYTVjNi05MjZk")
request2.sendRequest()