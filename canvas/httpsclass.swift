//
//  httpClass.swift
//  httpstest
//
//  Created by wu ted on 2021/11/24.
//

import Foundation
import Combine



class httpClass: NSObject, URLSessionDelegate {
    var ip: String = "https://fido2-demo.wisecure-tech.com:3000/register/queryStatus"
    var directorBearerToken: String
    //var baseURI: String
    private var getRequestCancellable: AnyCancellable?
    private var getRequestPublisher = PassthroughSubject<Data, Never>()
    
    init( token: String) {
       // self.ip = ip
        self.directorBearerToken = token
        //self.baseURI = "https://\(ip)"
    }
    // Get a JSON data with all the items
    func getAllItemInfo()  {
       sendControllerGetRequest(uri: "https://fido2-demo.wisecure-tech.com:3000/register/queryStatus")
        
    }
    func sendControllerGetRequest(uri: String)   {
        print("sendControllerGetRequest")
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "JWT", value:self.directorBearerToken )]
        getRequestPublisher = PassthroughSubject<Data, Never>()
        
        var urlRequest = URLRequest(url: URL(string: self.ip)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = requestBodyComponents.query?.data(using: .utf8)
        let configuration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        getRequestCancellable = session.dataTaskPublisher(for: urlRequest)
            .map{ $0.data }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("sendControllerGetRequest error")
                    print(error)
                case .finished:
                        print("sendControllerGetRequest finished")
                        break
                    }
                }, receiveValue: { requestDetails in
                    print(String(data: requestDetails, encoding: .utf8)!)
                    //print("sendControllerGetRequest()")
                    self.getRequestPublisher.send(requestDetails)
                    self.getRequestPublisher.send(completion: .finished)
                }
            )
        
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {//the delegate method
        //print("delegate:urlSession")
        if challenge.protectionSpace.serverTrust == nil {
            print("servertrusrt=nil")
            completionHandler(.useCredential, nil)
        } else {
            let securityTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: securityTrust)
            print("credential set to trust")
            completionHandler(.useCredential, credential)
        }
    }
}





