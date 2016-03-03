//
//  BasketViewController.swift
//  Solera
//
//  Created by Mark Woollard on 02/03/2016.
//  Copyright © 2016 Mark Woollard. All rights reserved.
//

import UIKit

let ServiceKey = "420b08b200183c7fb8d1040ccae18c98"
let BasketItemCell = "BasketItemCell"

class BasketViewController: UITableViewController {

    // MARK: Outlets
    @IBOutlet var currencyBarButtonItem: UIBarButtonItem!
    @IBOutlet var checkoutBarButtonItem: UIBarButtonItem!
    
    // MARK: Instance vars
    
    // Setup basket with stock 
    var viewModel = BasketViewModel(service: CurrencyLayerService(key: ServiceKey),
        stock: [
            BasketItem(itemTitle: "Bag of Peas", price: 0.95),
            BasketItem(itemTitle: "Dozen Eggs", price: 2.10),
            BasketItem(itemTitle: "Bottle of Milk", price: 1.30),
            BasketItem(itemTitle: "Can of Beans", price: 0.73)
        ])
    
    // Lazy formatter construction
    lazy var gbpFormatter:NSNumberFormatter = {
        let fmt = NSNumberFormatter()
        fmt.numberStyle = .CurrencyStyle
        fmt.currencySymbol = "£"
        return fmt
    }()

    lazy var formatter:NSNumberFormatter = {
        let fmt = NSNumberFormatter()
        fmt.numberStyle = .CurrencyStyle
        fmt.currencySymbol = ""
        return fmt
    }()

    // MARK: UITableViewDataSource / Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.basket.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = self.viewModel.basket[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(BasketItemCell, forIndexPath: indexPath)
        
        cell.textLabel?.text = item.itemTitle
        cell.detailTextLabel?.text = self.gbpFormatter.stringFromNumber(item.price)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.removeBasketItemAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.updateUIEnableState()
    }
    
    // MARK: Actions
    @IBAction func addItem(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Available Items", message: nil, preferredStyle: .ActionSheet)
        self.viewModel.stock.forEach { item in
            alert.addAction(UIAlertAction(title: item.itemTitle, style: .Default, handler: { (a) -> Void in
                self.viewModel.appendBasketItem(item)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.viewModel.basket.count-1, inSection: 0)], withRowAnimation: .Automatic)
                self.updateUIEnableState()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeCurrency(sender: AnyObject) {
    }
    
    /**
     Handle user checkout reqeust
     
     - parameter sender: Control issuing request
     */
    @IBAction func checkout(sender: AnyObject) {
        
        // Put up busy panel incase network operations take place to update currency
        let alert = UIAlertController(title: "Checking Out", message: nil, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        
        // Request checkout
        viewModel.checkoutPrice() { price, error in
            
            // On completion dismiss alert and dislay error or result
            self.dismissViewControllerAnimated(true) {
                if let error = error {
                    self.showError(error)
                } else {
                    let alert = UIAlertController(title: "Basket Total in \(self.viewModel.currency)", message: "\(self.formatter.stringFromNumber(price)!)", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: Lifecycle events
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var dest = segue.destinationViewController as? AcceptBasketViewModelType {
            dest.viewModel = self.viewModel
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.currencyBarButtonItem?.title = self.viewModel.currency
        self.updateUIEnableState()
    }

    override func viewDidAppear(animated: Bool) {
        if !self.viewModel.ratesAreValid {
            let alert = UIAlertController(title: "Getting rates", message: nil, preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            viewModel.updateRates { error in
                
                self.dismissViewControllerAnimated(true) {
                    if let error = error {
                        self.showError(error)
                    }
                }

                self.updateUIEnableState()
            }
        }
    }

    // Unwind segue action
    @IBAction func currencySelected(segue:UIStoryboardSegue) {
    }
    
    // MARK: Helper methods
    func updateUIEnableState() {
        self.currencyBarButtonItem.enabled = self.viewModel.ratesAreValid
        self.checkoutBarButtonItem.enabled = self.viewModel.basket.count > 0
    }
    
    // Show an error to the user
    private func showError(error:ErrorType) {
        let alert = UIAlertController(title: "Error", message: "An error occurred", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}