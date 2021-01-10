import Foundation

let scope = "https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope"
//  Base64Encode(client_id:client_secret)
let lariatOAuthToken = "U2FtaXVsSG8tTGFyaWF0LVBSRC03ZDRhMmZlNjYtNGIwMTBkZDA6UFJELWQ0YTJmZTY2OGMzZS01ZmM3LTRhNmQtYTVjNi05MjZk"

func sendAppOAuthRequest(grantType: String, authorizationCode: String) -> Void {
    let semaphore = DispatchSemaphore.init(value: 0)

    let url = URL(string: "https://api.ebay.com/identity/v1/oauth2/token")!
    var request = URLRequest(url: url)
    
    //  URLComponents is a structure that takes in URL components and constructs a URL
    var urlParameters = URLComponents()
    urlParameters.queryItems = [
        URLQueryItem(name: "grant_type", value: grantType),
        URLQueryItem(name: "scope", value: scope)
    ]
    
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue("Basic \(lariatOAuthToken)", forHTTPHeaderField: "Authorization")
    request.httpBody = urlParameters.query?.data(using: .utf8)

    let task = URLSession.shared.dataTask(with: request) {data, response, error in
        defer { semaphore.signal() }

        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No information provided about error")
            return
        }

    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
    if let responseJSON = responseJSON as? [String: Any] { print(responseJSON) }
    }

    task.resume()
    semaphore.wait()
}

sendAppOAuthRequest(grantType: "client_credentials", authorizationCode: "v%5E1.1%23i%5E1%23I%5E3%23p%5E3%23f%5E0%23r%5E1%23t%5EUl41XzExOkYzNzQxMTEwOEFCMDE2NEE2NEI1M0M5N0VEMTA5RDVGXzFfMSNFXjI2MA%3D%3D")
