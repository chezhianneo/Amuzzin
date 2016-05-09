//
//  AZConnectionManager.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 02/02/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

enum RequestType
{
    case RequestPost
    case RequestGet
}

class AZConnectionManager: NSObject,NSURLSessionDataDelegate,NSURLSessionTaskDelegate
{
    var requestPostDict:Dictionary<String,AnyObject>?
    var urlSession:NSURLSession?
    var requestType:RequestType?
    var operationQueue:NSOperationQueue?
    var requestHeader:Dictionary<String,AnyObject>?
    var requestDataTask:NSURLSessionDataTask?
    var mRequest:NSMutableURLRequest!
    var responseData:NSMutableData?
    var responseHeaders:Dictionary<String,AnyObject>?
    var jsonError : NSError?

    
    init(requestURl:NSURL?, requestIntType:RequestType)
    {
        
        /*{
            "user": {
                "email": "person1@example.com",
                "password": "12345678"
            }
        }
        */
        super.init()
        self.requestType = requestIntType
        mRequest = NSMutableURLRequest(URL: NSURL(string: "http://api.amuzz.in/auth")!)
        requestPostDict = ["user":["email":"neochezhian@gmail.com","passsword":"Amuzzin@889"]]
        
        //
    }
    
    
    func start()
    {
        urlSession = NSURLSession(configuration: sessionConfiguration(), delegate: self, delegateQueue: nil)
        setHTTPFields()
        requestDataTask = urlSession?.dataTaskWithRequest(mRequest)
        requestDataTask?.resume()
        
    }
    
    func setHTTPFields()
    {
        mRequest.allHTTPHeaderFields = nil

        switch requestType!
        {
        case .RequestPost:
            mRequest.HTTPMethod = "POST"
            
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(requestPostDict!, options: .PrettyPrinted)
                mRequest.HTTPBody = jsonData
                print("Reuquest Data \(String(data: mRequest.HTTPBody!, encoding: NSUTF8StringEncoding)))")
            }
            catch {
                print("JSON error \(error)")
            }
        case .RequestGet:
            mRequest.HTTPMethod = "GET"

        }
    }
    
    
    
    func sessionConfiguration() -> NSURLSessionConfiguration
    {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        return sessionConfig
    
    }
    

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void)
    {
        responseData = NSMutableData()
        NSLog("HTTP response %@", response)
        completionHandler(NSURLSessionResponseDisposition.Allow)

    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData)
    {
        responseData?.appendData(data)

    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?)
    {
        //      
        do {
            let jsonString = try NSJSONSerialization.JSONObjectWithData(responseData!, options: .MutableContainers)
            print("HTTP Response Data %@ \(jsonString)")
        }
        catch {
            print("Json Parsing Error \(error)")
        }
    }
}
