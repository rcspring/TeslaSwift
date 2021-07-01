//
//  TeslaModel.swift
//  TeslaSwift
//
//  Created by Ryan Spring on 6/22/21.
//  Copyright © 2021 Joao Nunes. All rights reserved.
//

import Foundation
import Combine

final class TeslaModel: ObservableObject {
    public var isAuthenticated: Bool {
        return token != nil && (token?.isValid ?? false)
    }
    
    static let shared = TeslaModel()
    private var nullBody = ""
    var useMockServer = false
    
    @Published fileprivate(set) var token: AuthToken?
    @Published fileprivate(set) var error: Error? {
        didSet {
            token = nil
        }
    }
}

extension TeslaModel {
    
    
    public func authenticateWeb()-> TeslaLoginView {

        let codeRequest = AuthCodeRequest()
        let endpoint = Endpoint.oAuth2Authorization(auth: codeRequest)
        var urlComponents = URLComponents(string: endpoint.baseURL())
        urlComponents?.path = endpoint.path
        urlComponents?.queryItems = endpoint.queryParameters

        let teslaWebLoginView = TeslaLoginView(url: urlComponents!.url!, model: self )

        return teslaWebLoginView
    }
    
    func handleCode(_ url: URL) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let queryItems = urlComponents?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "code", let code = queryItem.value {
                    print("Have code \(code)")
                    self.getAuthenticationTokenForWeb(code: code)
                    return
                }
            }
        }
    }
    
    private func getAuthenticationTokenForWeb(code: String) {

        let body = AuthTokenRequestWeb(code: code)

        request(.oAuth2Token, body: body) { [weak self] (result: Result<AuthToken, Error>) in
            guard let self = self else {
//                completion(Result.failure(TeslaError.authenticationFailed));
                return
                
            }

            DispatchQueue.main.async {
                switch result {
                    case .success(let token):
                    print("RCS got token \(token.accessToken)")
                        self.token = token
                    case .failure(let error):
                        if case let TeslaError.networkError(error: internalError) = error {
                            if internalError.code == 302 || internalError.code == 403 {
                                self.request(.oAuth2TokenCN, body: body) { (result: Result<AuthToken, Error>) in
                                    switch result {
                                    case .success(let token): self.token = token
                                    default: "Bad stuff happened."
                                    }
                                }
                            } else if internalError.code == 401 {
                                self.error = TeslaError.authenticationFailed
                            } else {
                                self.error = error
                            }
                        } else {
                            self.error = error 
                        }
                }
            }
        }

    }
    
    func request<ReturnType: Decodable, BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType,
                                                             completion: @escaping (Result<ReturnType, Error>) -> Void) {
        let request = prepareRequest(endpoint, body: body)

        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { completion(Result.failure(TeslaError.internalError)); return }
            guard error == nil else { completion(Result.failure(error!)); return }
            guard let httpResponse = response as? HTTPURLResponse else { completion(Result.failure(TeslaError.failedToParseData)) ;return }

            var responseString = "\nRESPONSE: \(String(describing: httpResponse.url))"
            responseString += "\nSTATUS CODE: \(httpResponse.statusCode)"
            if let headers = httpResponse.allHeaderFields as? [String: String] {
                responseString += "\nHEADERS: [\n"
                headers.forEach {(key: String, value: String) in
                    responseString += "\"\(key)\": \"\(value)\"\n"
                }
                responseString += "]"
            }

//            logDebug(responseString, debuggingEnabled: debugEnabled)

            if case 200..<300 = httpResponse.statusCode {
                do {
                    if let data = data {
                        let objectString = String.init(data: data, encoding: String.Encoding.utf8) ?? "No Body"
//                        logDebug("RESPONSE BODY: \(objectString)\n", debuggingEnabled: debugEnabled)

                        let mapped = try teslaJSONDecoder.decode(ReturnType.self, from: data)
                        completion(Result.success(mapped))
                    }
                } catch {
//                    logDebug("ERROR: \(error)", debuggingEnabled: debugEnabled)
                    completion(Result.failure(TeslaError.failedToParseData))
                }
            } else {
                if let data = data {
                    let objectString = String.init(data: data, encoding: String.Encoding.utf8) ?? "No Body"
//                    logDebug("RESPONSE BODY ERROR: \(objectString)\n", debuggingEnabled: debugEnabled)
                    if let wwwAuthenticate = httpResponse.allHeaderFields["Www-Authenticate"] as? String,
                       wwwAuthenticate.contains("invalid_token") {
                        completion(Result.failure(TeslaError.tokenRevoked))
                    } else if httpResponse.allHeaderFields["Www-Authenticate"] != nil, httpResponse.statusCode == 401 {
                        completion(Result.failure(TeslaError.authenticationFailed))
                    } else if let mapped = try? teslaJSONDecoder.decode(ErrorMessage.self, from: data) {
                        completion(Result.failure(TeslaError.networkError(error: NSError(domain: "TeslaError", code: httpResponse.statusCode, userInfo:[ErrorInfo: mapped]))))
                    } else {
                        completion(Result.failure(TeslaError.networkError(error: NSError(domain: "TeslaError", code: httpResponse.statusCode, userInfo: nil))))
                    }
                } else {
                    if let wwwAuthenticate = httpResponse.allHeaderFields["Www-Authenticate"] as? String {
                        if wwwAuthenticate.contains("invalid_token") {
                            completion(Result.failure(TeslaError.authenticationFailed))
                        }
                    } else {
                        completion(Result.failure(TeslaError.networkError(error: NSError(domain: "TeslaError", code: httpResponse.statusCode, userInfo: nil))))
                    }
                }
            }
        })

        task.resume()
    }
    
    func prepareRequest<BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType) -> URLRequest {
        var urlComponents = URLComponents(url: URL(string: endpoint.baseURL(useMockServer))!, resolvingAgainstBaseURL: true)
        urlComponents?.path = endpoint.path
        urlComponents?.queryItems = endpoint.queryParameters
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = endpoint.method
        
        request.setValue("TeslaSwift", forHTTPHeaderField: "User-Agent")
        
        if let token = self.token?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body as? String, body == nullBody {
            // Shrug
        } else {
            request.httpBody = try? teslaJSONEncoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "content-type")
        }
        
//        logDebug("\nREQUEST: \(request)", debuggingEnabled: debuggingEnabled)
//        logDebug("METHOD: \(request.httpMethod!)", debuggingEnabled: debuggingEnabled)
//        if let headers = request.allHTTPHeaderFields {
//            var headersString = "REQUEST HEADERS: [\n"
//            headers.forEach {(key: String, value: String) in
//                headersString += "\"\(key)\": \"\(value)\"\n"
//            }
//            headersString += "]"
////            logDebug(headersString, debuggingEnabled: debuggingEnabled)
//        }
        
        if let body = body as? String, body != nullBody {
            // Shrug
        } else if let jsonString = body.jsonString {
//            logDebug("REQUEST BODY: \(jsonString)", debuggingEnabled: debuggingEnabled)
        }
        
        return request
    }


}
