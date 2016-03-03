//
//  BasketViewModelUnitTests.swift
//  Solera
//
//  Created by Mark Woollard on 02/03/2016.
//  Copyright © 2016 Mark Woollard. All rights reserved.
//

import XCTest

struct MockCurrencyRates : CurrencyServiceRatesType {

    let sourceCurrency = "USD"
    let rates = testRateData
    let timestamp = NSDate()
}

class MockCurrencyService : CurrencyServiceType {
    
    func getLatestRates(source:String, resultHandler:(rates:CurrencyServiceRatesType?, error:ErrorType?) -> Void) -> CancellableCurrencyRequest? {
        
        resultHandler(rates: MockCurrencyRates(), error: nil)
        
        return nil
    }
}

/// Exercise features of basket view model
class BasketViewModelUnitTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDefaultCurrency() {
        let sut = BasketViewModel(service: MockCurrencyService(), stock: testStock)
        
        XCTAssertEqual("USD", sut.currency)
    }

    func testRatesAreValid() {
        let sut = BasketViewModel(service: MockCurrencyService(), stock: testStock)
        XCTAssertFalse(sut.ratesAreValid)
        
        sut.updateRates { _ in }
        
        XCTAssertTrue(sut.ratesAreValid)
    }
    
    func testChangingCurrency() {
        let sut = BasketViewModel(service: MockCurrencyService(), stock: testStock)
        
        sut.currency = "AUD"
        XCTAssertEqual("AUD", sut.currency)
        sut.currency = "CAD"
        XCTAssertEqual("CAD", sut.currency)
    }

    func testThereIsStock() {
        let sut = BasketViewModel(service: MockCurrencyService(), stock: testStock)

        sut.stock.forEach {
            XCTAssertLessThan(0, $0.itemTitle.characters.count)
            XCTAssertLessThan(0, $0.price)
        }
    }
    
    func testAddingItems() {
        
        let sut = BasketViewModel(service: MockCurrencyService(), stock: testStock)
        sut.appendBasketItem(sut.stock[0])
        sut.appendBasketItem(sut.stock[3])
        XCTAssertEqual(2, sut.basket.count)
        XCTAssertEqual(sut.stock[0].itemTitle, sut.basket[0].itemTitle)
        XCTAssertEqual(sut.stock[3].itemTitle, sut.basket[1].itemTitle)
        XCTAssertEqual(sut.stock[0].price, sut.basket[0].price)
        XCTAssertEqual(sut.stock[3].price, sut.basket[1].price)
    }
    
    func testRemovingItems() {
        
        let sut = BasketViewModel(service: MockCurrencyService(), stock: testStock)
        sut.appendBasketItem(sut.stock[0])
        sut.appendBasketItem(sut.stock[3])
        XCTAssertEqual(2, sut.basket.count)
        sut.removeBasketItemAtIndex(1)
        XCTAssertEqual(1, sut.basket.count)
        XCTAssertEqual(sut.stock[0].itemTitle, sut.basket[0].itemTitle)
        XCTAssertEqual(sut.stock[0].price, sut.basket[0].price)
        sut.removeBasketItemAtIndex(0)
        XCTAssertEqual(0, sut.basket.count)
    }
 
    func testRates() {

        let sut = BasketViewModel(service: MockCurrencyService(), stock: testStock)
        
        // Initially should be no rates
        XCTAssertNil(sut.rates)
        
        // Update rates
        sut.updateRates { _ in }

        // Now should have rates
        XCTAssertNotNil(sut.rates)
        
        // Validate they match test data
        sut.rates!.forEach { (currency, rate) in
            XCTAssertEqual(testRateData[currency]!, sut.rates![currency])
        }
    }
    
    func testCheckout() {
        
        let sut = BasketViewModel(service: MockCurrencyService(), stock: testStock)

        sut.updateRates { _ in }
        
        // Add 10 random items from stock
        (0..<10).forEach { _ in
            let stockIndex = Int(arc4random_uniform(UInt32(sut.stock.count)))
            sut.appendBasketItem(sut.stock[sut.stock.startIndex.advancedBy(stockIndex)])
        }
        
        (0..<10).forEach { _ in
            // Pick a random rate
            let rateIndex = Int(arc4random_uniform(UInt32(sut.rates!.count)))
            sut.currency = sut.rates!.keys[sut.rates!.keys.startIndex.advancedBy(rateIndex)]
            let rate = 1.0 / sut.rates!["GBP"]! * sut.rates![sut.currency]!
            
            // Work out expected price
            let result = sut.basket.reduce(0.0) { sum, item in
                return sum + item.price
            } * rate

            // Exercise checkout
            sut.checkoutPrice { (total, error) -> Void in
                XCTAssertEqualWithAccuracy(result, total, accuracy: 0.00001)
            }
        }
    }
}
