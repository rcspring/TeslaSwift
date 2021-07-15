//
//  TeslaModel.swift
//  TeslaSwift
//
//  Created by Ryan Spring on 6/22/21.
//  Copyright © 2021 Joao Nunes. All rights reserved.
//

import Foundation
import Combine

public enum OperationType {
    case vehicles
}

@MainActor
public final class TeslaBase: ObservableObject {
    public var isAuthenticated: Bool {
        return token != nil && (token?.isValid ?? false)
    }
    
    public static let shared = TeslaBase()
    private var nullBody = ""
    
    @Published fileprivate(set) var token: AuthToken?
    @Published fileprivate(set) var vehicles: [Vehicle] = []
    @Published fileprivate(set) var error: Error? {
        didSet {
            token = nil
        }
    }
}

extension TeslaBase {
    
    private func checkToken() -> Bool {
        if let token = self.token {
            return token.isValid
        } else {
            return false
        }
    }
    
//    public func getVehicles() async throws {
//        try await checkAuthentication()
//        let result: ArrayResponse<Vehicle> = try await request(.vehicles, body: "")
//        self.vehicles = result.response
//    }
    
    @discardableResult
    private func checkAuthentication() async throws -> AuthToken {
        guard let token = self.token else { throw TeslaError.authenticationRequired }

        if checkToken() {
            return token
        } else {
            if token.refreshToken != nil {
                if token.isOAuth {
                    let token = try await refreshWebToken()
                    return token
                } else {
                    let token = try await refreshToken()
                    return token 
                }
            } else {
                throw TeslaError.authenticationRequired
            }
        }
    }
    
    @discardableResult
    private func refreshWebToken() async throws -> AuthToken{
        guard let token = self.token else {
            throw TeslaError.noTokenToRefresh
        }
        let body = AuthTokenRequestWeb(grantType: .refreshToken, refreshToken: token.refreshToken)

        let newToken: AuthToken = try await request(.oAuth2Token, body: body)
        
        self.token = newToken
        return newToken
    }
    
    @discardableResult
    private func refreshToken() async throws -> AuthToken {
        guard let token = self.token else {
            throw TeslaError.noTokenToRefresh
        }
        let body = AuthTokenRequest(grantType: .refreshToken, refreshToken: token.refreshToken)
        
        let newToken: AuthToken = try await request(.authentication, body: body)
        self.token = newToken
        
        return newToken
    }
                      
    public func authenticateWeb()-> TeslaLoginView {

        let codeRequest = AuthCodeRequest()
        let endpoint = Endpoint.oAuth2Authorization(auth: codeRequest)
        var urlComponents = URLComponents(string: endpoint.baseURL())
        urlComponents?.path = endpoint.path
        urlComponents?.queryItems = endpoint.queryParameters

        let teslaWebLoginView = TeslaLoginView(url: urlComponents!.url!, model: self )

        return teslaWebLoginView
    }
    
    func handleCode(_ url: URL) async throws -> Void {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let queryItems = urlComponents?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "code", let code = queryItem.value {
                    print("Have code \(code)")
                    try await self.getAuthenticationTokenForWeb(code: code)
                    return
                }
            }
        }
    }
    
    private func getAuthenticationTokenForWeb(code: String) async throws {

        let body = AuthTokenRequestWeb(code: code)

        let token: AuthToken = try await request(.oAuth2Token, body: body)
        
        self.token = token
    }
    
    public func request<ReturnType: Decodable>(_ operation: OperationType) async throws -> [ReturnType] {
        switch operation {
        case .vehicles:
            return try await request(Endpoint.vehicles)
        }
    }
    
    private func request<ReturnType: Decodable>(_ endpoint: Endpoint) async throws -> [ReturnType] {
        let result: ArrayResponse<ReturnType> = try await request(endpoint, body: nullBody)
        
        return result.response
    }
    
    private func request<ReturnType: Decodable, BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType) async throws ->
    ReturnType {
        let request = prepareRequest(endpoint, body: body)
        
        let result = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = result.1 as? HTTPURLResponse else { throw TeslaError.failedToParseData }
        
        switch response.statusCode {
        case 200..<300:
            do {
                let mapped = try teslaJSONDecoder.decode(ReturnType.self, from: result.0)
                return mapped
            } catch {
                throw error
            }
        default:
            throw TeslaError.authenticationFailed
            
        }
        
    }
        
    func prepareRequest<BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType) -> URLRequest {
        var urlComponents = URLComponents(url: URL(string: endpoint.baseURL(false))!, resolvingAgainstBaseURL: true)
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
        
        return request
    }


}

extension Vehicle: Identifiable {
    
}
