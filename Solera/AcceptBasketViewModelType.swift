//
//  BasketViewControllerType.swift
//  Solera
//
//  Created by Mark Woollard on 02/03/2016.
//  Copyright © 2016 Mark Woollard. All rights reserved.
//

import Foundation

/**
 *  Defines controllers that can accept passing of a BasketViewModel instance
 */
protocol AcceptBasketViewModelType {
    
    var viewModel:BasketViewModel? { get set }
    
}