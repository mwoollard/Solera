//
//  RatePickerViewController.swift
//  Solera
//
//  Created by Mark Woollard on 02/03/2016.
//  Copyright © 2016 Mark Woollard. All rights reserved.
//

import UIKit

let RateCell = "RateCell"

class RatePickerViewController : UITableViewController, AcceptBasketViewModelType, UISearchResultsUpdating {
    
    // MARK: Instance variables
    var viewModel:BasketViewModel?
    var rates:[String] = [String]()
    var searchController:UISearchController?
    let searchQueue = NSOperationQueue()
    
    // MARK: Lifecyle events
    override func viewDidLoad() {
        super.viewDidLoad()

        // Trigger inital unfilted rates update
        updateRates("")
        
        // Set up search controller
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController!.searchResultsUpdater = self
        self.searchController!.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController!.searchBar
    }
    
    deinit {
        self.searchQueue.cancelAllOperations()
    }

    // MARK: UITableViewDataSource / Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rates.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let currency = self.rates[indexPath.row]
        let rate = self.viewModel!.rates![currency]!
        
        let cell = tableView.dequeueReusableCellWithIdentifier(RateCell, forIndexPath: indexPath)
        cell.textLabel?.text = "USD:\(currency)"
        cell.detailTextLabel?.text = "\(rate)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currency = self.rates[indexPath.row]
        self.viewModel?.currency = currency
    }

    /**
     Updates the rates displayed asychronously applyingfiltering and sorting
     
     - parameter filter: Filter string
     */
    func updateRates(filter:String) {
        let cleanFilter = filter.stringByTrimmingWhiteSpace().uppercaseString
        self.searchQueue.cancelAllOperations()
        let op = NSBlockOperation()
        op.addExecutionBlock() { [weak self] in
            if let sorted = self?.viewModel!.rates!.keys.sort() {
                var filtered:[String]?
                if filter.characters.count > 0 {
                    filtered = sorted.filter { $0.containsString(cleanFilter) }
                } else {
                    filtered = sorted
                }
                if !op.cancelled {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self?.rates = filtered!
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        
        self.searchQueue.addOperation(op)
    }

    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        updateRates(searchController.searchBar.text!.uppercaseString)
    }
    
}
