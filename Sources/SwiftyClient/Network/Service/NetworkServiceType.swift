//
//  NetworkServiceType.swift
//  TodoJobLogic
//
//  Created by umair irfan on 18/01/2024.
//
import Combine
import Foundation

protocol NetworkServiceType {
    func request<T>(apiClient: APIClient, route: ClientRequestConvertible,
                    retries: Int, thread: RunLoop) -> AnyPublisher<T, NetworkError> where T: Decodable
}
