// The Swift Programming Language
// https://docs.swift.org/swift-book
import Combine
import Alamofire
import Foundation

public typealias ClientRequestConvertible = URLRequestConvertible
public typealias ClientHTTPMethod = HTTPMethod
public typealias ClientResponse = AnyPublisher<APIResponseConvertible, NetworkError>

public protocol APIClient {
    func request(route: ClientRequestConvertible) -> ClientResponse
}
