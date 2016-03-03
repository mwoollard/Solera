//
//  BasketViewModel.swift
//  Solera
//
//  Created by Mark Woollard on 02/03/2016.
//  Copyright © 2016 Mark Woollard. All rights reserved.
//

import Foundation

// An item of stock that can be purchased
struct BasketItem {
    let itemTitle:String
    let price:Double
}

let ValidRatePeriod = 60.0 * 60.0 * 24.0 // One day

/// Models a shopping basket and set of stock items to purchase
class BasketViewModel {
    
    private var _basket = [BasketItem]()
    private var _rates:CurrencyServiceRatesType?
    private var _service:CurrencyServiceType
    
    init(service:CurrencyServiceType, stock:[BasketItem]) {
        _service = service
        self.stock = stock
    }

    let stock:[BasketItem]
    
    var currency:String = "USD"
    
    var basket:[BasketItem] {
        return _basket
    }
    
    var rates:[String:Double]? {
        return _rates?.rates
    }
    
    var ratesAreValid:Bool {
        if let timestamp = _rates?.timestamp {
            return timestamp.timeIntervalSinceNow > -ValidRatePeriod
        }
        
        return _rates != nil
    }
    
    func appendBasketItem(item:BasketItem) {
        _basket.append(item)
    }
    
    func removeBasketItemAtIndex(index:Int) {
        
        guard index >= 0 && index < _basket.count else {
            return // Return if index out of range - could throw, or have an error return
        }
        
        _basket.removeAtIndex(index)
    }

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