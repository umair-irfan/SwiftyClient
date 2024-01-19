//
// WebClient.swift
//
//
//  Created by umair irfan on 19/01/2024.
//
import Combine
import Foundation

fileprivate typealias WebClientResponse = Future<APIResponseConvertible, NetworkError>

public class WebClient: APIClient {
    
    private var urlSession: URLSession
    
    public init() {
        urlSession = URLSession(configuration: .default)
    }
    
    public func request(route: ClientRequestConvertible) -> ClientResponse {
        
        guard Reachability.networkConection else {
            return Fail(error: NetworkError.noInternet).eraseToAnyPublisher()
        }
        
        guard let urlRequest = route.urlRequest else {
            return Fail(error: NetworkError.invalidRequest).eraseToAnyPublisher()
        }
        
        debug(urlRequest: urlRequest)
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw NetworkError.unknown
                }
                self.debug(response: data)
                let apiResponse = APIResponse(code: httpResponse.statusCode, data: data)
                return apiResponse
            }
            .mapError { error in
                if let error = error as? NetworkError {
                    return error
                } else {
                    return NetworkError.serverError(error: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: Debug Extention
private extension WebClient {
    
    func debug(urlRequest: URLRequest?) {
        if let url = urlRequest?.url?.absoluteString {
            debugPrint(url + " -> REQUEST " + (String(data: urlRequest?.httpBody ?? Data(),
                                                      encoding: .utf8) ?? "Failed to Convert"))
        }
    }
    
    func debug(response: Data) {
        #if DEBUG
        String(data: response, encoding: .utf8 ).map { print("Response:" + $0) }
        #endif
    }
}
