//
//  MasterViewController.swift
//  Animals IAP Example
//
//  Created by Julian Boxnick on 20.03.22.
//

import UIKit
import StoreKit

class MasterViewController: UITableViewController {
    
    //MARK: - Properties
    
    let showDetailSegueIdentifier = "showDetail"
    
    var products: [SKProduct] = []
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupRefreshControl()
        setupNavigation()
        setupNotifications()
        
        reload()
    }
    
    //MARK: - Setup Functions
    
    private func setupViews() {
        
        title = "Tiere"
    }
    
    private func setupRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(MasterViewController.reload), for: .valueChanged)
    }
    
    private func setupNavigation() {
        
        let restoreButton = UIBarButtonItem(title: "Wiederherstellen", style: .plain, target: self,
                                            action: #selector(MasterViewController.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
    }
    
    private func setupNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == showDetailSegueIdentifier {
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return false
            }
            
            let product = products[indexPath.row]
            
            return AnimalsIAPExampleProducts.store.isProductPurchased(product.productIdentifier)
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showDetailSegueIdentifier {
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let product = products[indexPath.row]
            
            if let name = resourceNameForProductIdentifier(product.productIdentifier),
               let detailViewController = segue.destination as? DetailViewController {
                let image = UIImage(named: name)
                detailViewController.image = image
            }
        }
    }
    
    //MARK: - @objc Functions
    
    @objc func reload() {
        
        products = []
        
        tableView.reloadData()
        
        AnimalsIAPExampleProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func restoreTapped(_ sender: AnyObject) {
        
        AnimalsIAPExampleProducts.store.restorePurchases()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let index = products.firstIndex(where: { product -> Bool in
                product.productIdentifier == productID
            })
        else { return }
        
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}

//MARK: - UITableViewDataSource + UITableViewDelegate

extension MasterViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ProductCell else { return UITableViewCell() }
        
        let product = products[indexPath.row]
        
        cell.product = product
        cell.buyButtonHandler = { product in
            AnimalsIAPExampleProducts.store.buyProduct(product)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
      return 80
    }
}

//MARK: - Notification.Name Extension

extension Notification.Name {
    
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
}
