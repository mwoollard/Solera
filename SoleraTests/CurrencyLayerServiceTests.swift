//
//  CurrencyLayerServiceTests.swift
//  Solera
//
//  Created by Mark Woollard on 02/03/2016.
//  Copyright © 2016 Mark Woollard. All rights reserved.
//

import XCTest

class CurrencyLayerServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
     Test a request to get currency from provider works as expected
     */
    func testServiceRequest() {
        
        let sut = CurrencyLayerService(key:serviceKey)
        
        let expectation = self.expectationWithDescription("currency rates expectation")
        
        sut.getLatestRates("USD") { rates, error in
            
            XCTAssertNil(error)
            XCTAssertTrue(rates != nil)
            XCTAssertLessThan(0, rates!.rates.count)
            XCTAssertEqual("USD", rates!.sourceCurrency)
            XCTAssertLessThan(-60*60*24, rates!.timestamp.timeIntervalSinceNow)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
