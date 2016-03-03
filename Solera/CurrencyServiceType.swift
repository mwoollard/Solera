//
//  CurrencyServiceType.swift
//  Solera
//
//  Created by Mark Woollard on 02/03/2016.
//  Copyright © 2016 Mark Woollard. All rights reserved.
//

import Foundation

// Possible errors from service
public enum CurrencyServiceError : ErrorType {
    case InvalidServerResponse
}

// Cancellable type returned by request for data
public protocol CancellableCurrencyRequest {
    func cancel()
}

// Full set of currency data
public protocol CurrencyServiceRatesType {
    var sourceCurrency:String { get }   // Source currency, always USD for free service
    var rates:[String:Double] { get }   // Mapping between currency and exchange rate from USD
    var timestamp:NSDate { get }        // Timestamp the currency data is for
}

// Service definition
public protocol CurrencyServiceType {
    
    /**
     Initiate a request to get a currency data update
     
     - parameter source:        The source currency, for free API "USD" is only accepted value
     - parameter resultHandler: Closure to handle response
     
     - returns: Cancellable request object
     */
    func getLatestRates(source:String, resultHandler:(rates:CurrencyServiceRatesType?, error:ErrorType?) -> Void) -> CancellableCurrencyRequest?
    
}