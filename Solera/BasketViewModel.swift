//
//  BasketViewModel.swift
//  Solera
//
//  Created by Mark Woollard on 02/03/2016.
//  Copyright © 2016 Mark Woollard. All rights reserved.
//

import Foundation

// An item of stock that can be purchased
public struct BasketItem {
    let itemTitle:String
    let price:Double
}

let ValidRatePeriod = 60.0 * 60.0 * 24.0 // One day

/// Models a shopping basket and set of stock items to purchase
public class BasketViewModel {
    
    private var _basket = [BasketItem]()
    private var _rates:CurrencyServiceRatesType?
    private var _service:CurrencyServiceType
    
    /**
     Initialise basket with currency provider service and set of stock items
     
     - parameter service: Currency service provider
     - parameter stock:   Stock items
     
     - returns: Initialised instance
     */
    public init(service:CurrencyServiceType, stock:[BasketItem]) {
        _service = service
        self.stock = stock
    }

    // MARK: Public properties
    
    // Stock items that can be added basket
    public let stock:[BasketItem]
    
    // Current target currency
    public var currency:String = "USD"
    
    // Current basket contents
    public var basket:[BasketItem] {
        return _basket
    }
    
    // Current rates, nil not yet obtained
    public var rates:[String:Double]? {
        return _rates?.rates
    }
    
    // Are rates valid? Checks they exist and not more than a day old
    public var ratesAreValid:Bool {
        if let timestamp = _rates?.timestamp {
            return timestamp.timeIntervalSinceNow > -ValidRatePeriod
        }
        
        return _rates != nil
    }
    
    /**
     Append an item to the basket
     
     - parameter item: Item to append
     */
    func appendBasketItem(item:BasketItem) {
        _basket.append(item)
    }
    
    /**
     Remove an item from the basket
     
     - parameter index: Index of item to remove
     */
    func removeBasketItemAtIndex(index:Int) {
        
        guard index >= 0 && index < _basket.count else {
            return // Return if index out of range - could throw, or have an error return
        }
        
        _basket.removeAtIndex(index)
    }

    /**
     Update rates from rate provider, asynchronous
     
     - parameter completion: Closure completed when done, passing back any error
     */
    func updateRates(completion:(ErrorType?) -> Void) {
    
        if ratesAreValid {
            completion(nil)
            return
        }
        
        _service.getLatestRates("USD") { (rates, error) -> Void in
            if error != nil {
                completion(error)
                return
            }
            
            if rates == nil {
                completion(CurrencyServiceError.InvalidServerResponse)
            }
            
            self._rates = rates
            completion(nil)
        }
    }
    
    /**
     Checkout the basket to work out price of items in current currency, async as may update
     rates as part of process.
     
     - parameter completion: Closure called when complete with total or error
     */
    func checkoutPrice(completion:(total:Double, error:ErrorType?) -> Void) -> Void {

        self.updateRates { error in
            if error != nil {
                completion(total: 0.0, error:error)
                return
            }
            
            let totalGBP = self.basket.reduce(0.0) { total, item in
                return total + item.price
            }
            
            let gbpToUsd = 1.0 / self._rates!.rates["GBP"]!
            let usdToTarget = self._rates!.rates[self.currency]!
            
            completion(total: totalGBP * gbpToUsd * usdToTarget, error: nil)
        }
    }
}