//
//  DataRequestExtensions.swift
//  YapAiTek-Assessment
//
//  Created by tanaz on 9/29/1399 AP.
//



import Foundation

import Alamofire

public extension DataRequest {
    
    @discardableResult
    func log() -> Self {
        self.logRequest()
        return self.logResponse()
    }
    
    @discardableResult
    func logRequest() -> Self {
        guard
            let method = self.request?.httpMethod,
            let url = self.request?.url else {
                return self
        }
        var message = "[REQUEST] \(method) \(url)"
        
        if let headers = self.request?.allHTTPHeaderFields {
            for header in headers {
                message += "\n\(header.key): \(header.value)"
            }
        }
        if let data = self.request?.httpBody,
            let body = String(data: data, encoding: .utf8) {
            message += "\n\(body)"
        }
        
        return self
    }
    
    @discardableResult
    func logResponse() -> Self {
        return self.response(completionHandler: {
            guard
                let method = $0.request?.httpMethod,
                let url = $0.request?.url else {
                    return
            }
            
            var message = "[RESPONSE] \(method) \($0.response?.statusCode ?? -1) \(url) \(String(format: "%.3fms", $0.timeline.requestDuration * 1000))"
            
            if let err = $0.error?.localizedDescription {
                message += " [!] \(err)"
            }
            
            
            if let headers = $0.response?.allHeaderFields {
                for header in headers {
                    message += "\n\(header.key): \(header.value)"
                }
            }
            if let data = $0.data,
                let body = String(data: data, encoding: .utf8) {
                if body.count > 0 {
                    message += "\n\(body)"
                }
            }
            
        })
    }
}

extension DataRequest {
    
    enum ErrorCode: Int {
        case noData = 1
        case dataSerializationFailed = 2
    }
    
    internal static func newError(_ code: ErrorCode, failureReason: String) -> NSError {
        let errorDomain = "com.alamofireCodable.error"
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let returnError = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
        return returnError
    }
    
    /// Utility function for checking for errors in response
    internal static func checkResponseForError(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) -> Error? {
        if let error = error {
            return error
        }
        guard let _ = data else {
            let failureReason = "Data could not be serialized. Input data was nil."
            let error = newError(.noData, failureReason: failureReason)
            return error
        }
        return nil
    }
    
    /// Utility function for extracting JSON from response
    internal static func processResponse(request: URLRequest?, response: HTTPURLResponse?, data: Data?, keyPath: String?) -> Any? {
        let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
        let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)

        let JSON: Any?
        if let keyPath = keyPath , keyPath.isEmpty == false {
            JSON = (result.value as AnyObject?)?.value(forKeyPath: keyPath)
        } else {
            JSON = result.value
        }
        return JSON
    }
    
    /// Codable Object Serializer
    public static func ObjectSerializer<T: Codable>(_ keyPath: String?) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            if let error = checkResponseForError(request: request, response: response, data: data, error: error){
                return .failure(error)
            }
            let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath)
            do {
                if let JSONObject = JSONObject, let newData = try? JSONSerialization.data(withJSONObject: JSONObject, options: [.prettyPrinted]){
                    let object = try JSONDecoder().decode(T.self, from: newData)
                    return .success(object)
                } else {
                    let failureReason = "JSONDecoder failed to serialize response."
                    let error = newError(.dataSerializationFailed, failureReason: failureReason)
                    return .failure(error)
                }
            } catch let error {
                return .failure(error)
            }
        }
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - Parameters:
    ///   - queue:              The queue on which the completion handler is dispatched.
    ///   - keyPath:            The key path where object mapping should be performed
    ///   - completionHandler:  A closure to be executed once the request has finished and the data has been decoded by JSONDecoder.
    /// - Returns:              The request.
    @discardableResult
    public func responseObject<T: Codable>(queue: DispatchQueue? = nil, keyPath: String? = nil,  completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectSerializer(keyPath), completionHandler: completionHandler)
    }
    
    /// Codable Array Serializer
    public static func ObjectArraySerializer<T: Codable>(_ keyPath: String?) -> DataResponseSerializer<[T]> {
        return DataResponseSerializer { request, response, data, error in
            if let error = checkResponseForError(request: request, response: response, data: data, error: error){
                return .failure(error)
            }
            let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath)
            do {
                if let JSONObject = JSONObject, let newData = try? JSONSerialization.data(withJSONObject: JSONObject, options: [.prettyPrinted]){
                    let object = try JSONDecoder().decode([T].self, from: newData)
                    return .success(object)
                } else {
                    let failureReason = "JSONDecoder failed to serialize response."
                    let error = newError(.dataSerializationFailed, failureReason: failureReason)
                    return .failure(error)
                }
            } catch let error {
                return .failure(error)
            }
        }
    }
    
    
    /// Adds a handler to be called once the request has finished. T: Codable
    ///
    /// - Parameters:
    ///   - queue:              The queue on which the completion handler is dispatched.
    ///   - keyPath:            The key path where object mapping should be performed
    ///   - completionHandler:  A closure to be executed once the request has finished and the data has been decoded by JSONDecoder.
    /// - Returns:              The request.
    @discardableResult
    public func responseArray<T: Codable>(queue: DispatchQueue? = nil, keyPath: String? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectArraySerializer(keyPath), completionHandler: completionHandler)
    }
}
