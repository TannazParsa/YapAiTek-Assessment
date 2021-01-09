//
//  WebServices.swift
//  YapAiTek-Assessment
//
//  Created by tanaz on 9/28/1399 AP.
//

import Foundation
import Alamofire
import RxSwift

enum Result<T> {
    case success(value: Codable)
    case failure(error: String, code: Int)
}
class WebServices: RequestRetrier {

    static let shared = WebServices()
    var sessionManager: SessionManager!
    private let lock = NSLock()
    private var requestsToRetry: [RequestRetryCompletion] = []

    init() {
        sessionManager = Alamofire.SessionManager.default
        sessionManager.retrier = self
    }
    // retry request if got error
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {

        lock.lock() ; defer { lock.unlock() }

        if let response = request.task?.response as? HTTPURLResponse {
               if response.statusCode == 401 {
                   requestsToRetry.append(completion)

               } else {
                   if request.retryCount == 3 { completion(false, 0.0 ); return}
                   completion(true, 1.0)
                   return
               }
           } else {
               completion(false, 0.0)
           }
    }

    func request<T: Codable>(url: String,
                             param: Parameters? = nil,
                             method: HTTPMethod = .post,
                             encoding: ParameterEncoding = JSONEncoding.default,
                             headers: [String: String]? = nil, isAutorization: Bool = true) -> Observable<Result<T>> {

        let observer = PublishSubject<Result<T>>()

    Alamofire.request(url, method: method, parameters: param, encoding: encoding)
        .validate()
        .log()
        .responseObject { (response: DataResponse<T>) in

        let json = try? JSONSerialization.jsonObject(with: response.data ?? Data(), options: []) as? [String: Any]
        print(json as Any)

            guard let jsonData = response.data, let articleContent = try?  JSONDecoder().decode(T.self, from: jsonData) else {
                guard let jsonData = response.data else {
                print("is nil")
                return}

                guard let error = try? JSONDecoder().decode(ApiError.self, from: jsonData) else {return}
                observer.onNext(Result.failure(error: error.message ?? "", code: error.code ?? 0))
                return

            }
                print(articleContent)
        switch response.result {
        case .success(let object):
            debugPrint(object)
            observer.onNext(Result.success(value: articleContent))

        case .failure(let error):
            debugPrint(error.localizedDescription)
            guard let jsonData = response.data else {
                print("is nil")
                return}
            guard let error = try? JSONDecoder().decode(ApiError.self, from: jsonData) else {return}
                print(error)
            observer.onNext(Result.failure(error: error.message ?? "", code: error.code ?? 0))
        }
    }
    return observer

    }
}
