//
//  CurrencyLayerService.swift
//  Solera
//
//  Created by Mark Woollard on 02/03/2016.
//  Copyright © 2016 Mark Woollard. All rights reserved.
//

import Foundation

let LiveRequestURL = "http://apilayer.net/api/live"
let AccessKeyParam = "access_key"

// So NSURLSessionTask is CancellableCurrenctRequest
extension NSURLSessionTask : CancellableCurrencyRequest {
    
}

// Service to get currency rates from Currency Layer server
public class CurrencyLayerService : CurrencyServiceType {
    
    /**
     *  Internal implementation of currency rates type
     */
    private struct Rates : CurrencyServiceRatesType {
        let sourceCurrency:String
        let rates:[String:Double]
        let timestamp:NSDate
        
        init(sourceCurrency:String, rates:[String:Double], timestamp:NSDate) {
            self.sourceCurrency = sourceCurrency
            self.rates = rates
            self.timestamp = timestamp
        }
    }
        
    private let key:String
    
    init(key:String) {
        self.key = key
    }
    
    /**
     Parse JSON data to validate and extract currency data
     
     - parameter data:           NSData to decode to JSON
     - parameter expectedSource: Expected source currency type
     
     - throws: If any error or data validation throws error
     
     - returns: Complete set of rates
     */
    private func parseJSONData(data:NSData, expectedSource:String) throws -> Rates {
        
        // Parse JSON
        let rootObject = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue: 0))
        
        // Validate response JSON structure
        guard let success = rootObject.objectForKey("success") as? Bool else {
            throw CurrencyServiceError.InvalidServerResponse
        }

        guard let timestamp = rootObject.objectForKey("timestamp") as? Int else {
            throw CurrencyServiceError.InvalidServerResponse
        }
        
        guard let source = rootObject.objectForKey("source") as? String else {
            throw CurrencyServiceError.InvalidServerResponse
        }
        
        guard let quotes = rootObject.objectForKey("quotes") as? [String:Double] else {
            throw CurrencyServiceError.InvalidServerResponse
        }
    
        if !success || source != expectedSource {
            throw CurrencyServiceError.InvalidServerResponse
        }

        // Map from 6 character strings to 3 character destination code
        var results = [String:Double]()
        quotes.keys.forEach {
            results[$0.substringFromIndex($0.startIndex.advancedBy(3))] = quotes[$0]
        }
        
        return Rates(sourceCurrency:expectedSource, rates:results, timestamp: NSDate(timeIntervalSince1970: Double(timestamp)))
    }
    
    /**
     Get latest currency rates from Currency Layer server
     
     - parameter source:        Source currency to request
     - parameter resultHandler: Handler for repsonse
     
     - returns: Cancellable object
     */
    public func getLatestRates(source:String, resultHandler:(rates:CurrencyServiceRatesType?, error:ErrorType?) -> Void) -> CancellableCurrencyRequest? {
        
        let urlString = "\(LiveRequestURL)?\(AccessKeyParam)=\(key.stringByURLEncodingAsQueryParameterValue())"
        guard let url = NSURL(string: urlString) else {
            return nil
        }
        
        let urlRequest = NSURLRequest(URL: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
        
            guard error == nil else {
                resultHandler(rates: nil, error: error)
                return
            }
            
            guard let data = data else {
                resultHandler(rates: nil, error: CurrencyServiceError.InvalidServerResponse)
                return
            }
            
            do {
                let result = try self.parseJSONData(data, expectedSource: "USD")
                resultHandler(rates: result, error: nil)
            } catch {
                resultHandler(rates: nil, error: error)
            }
        }
        
        task.resume()
        
        return task
    }
}