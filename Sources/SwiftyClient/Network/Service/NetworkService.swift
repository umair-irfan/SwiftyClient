//
//  NetworkService.swift
//  TodoJobLogic
//
//  Created by umair irfan on 18/01/2024.
//
import Combine
import Foundation

/// All applictcation services Shall Inherit from Network Service to extend the functionality
/// NetwrokService class the base class containing the primary response validations
/// Responsibility of this class is to decode the network response and
/// handle network exceptions
open class NetworkService: NetworkServiceType {
    
    func request<T>(apiClient: APIClient, route: ClientRequestConvertible, retries: Int = 0, thread: RunLoop = .main) -> AnyPublisher<T, NetworkError> where T: Decodable {
        // MARK: request is URLSession Method
        return apiClient.request(route: route)
            .tryMap { apiResponse -> APIResponseConvertible in
                //MARK:  Internal Server Errors
                guard 200...299 ~= apiResponse.code else {
                    throw NetworkErrorHandler.mapError(apiResponse.code, data: apiResponse.data)
                }
                //MARK: Returns (Response) to (Decoder)
                return apiResponse
            }
            // MARK: Response Decoding
            .tryMap { apiResponse -> T in
                do {
                    //let object: Response<T> = try self.decode(data: apiResponse.data)
                    return try self.decode(data: apiResponse.data)
                } catch {
                    // MARK: Decoding Error
                    throw error
                }
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    //MARK: Decoding Error
                    return NetworkError.unknown
                }
            }
            .receive(on: thread)
            .retry(retries)
            .eraseToAnyPublisher()
    }
}

private extension NetworkService {
    func decode<T>(data: Data) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
