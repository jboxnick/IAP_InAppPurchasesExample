//
//  IAPHelper.swift
//  Animals IAP Example
//
//  Created by Julian Boxnick on 20.03.22.
//

import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void


func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}


public struct AnimalsIAPExampleProducts {
    
    private static let productIdentifiers: Set<ProductIdentifier> = ["de.JBCodes.Animals_IAP_Example.elefant", "de.JBCodes.Animals_IAP_Example.erdmaennchen", "de.JBCodes.Animals_IAP_Example.giraffe", "de.JBCodes.Animals_IAP_Example.kampffisch", "de.JBCodes.Animals_IAP_Example.koala", "de.JBCodes.Animals_IAP_Example.panda", "de.JBCodes.Animals_IAP_Example.pinguin", "de.JBCodes.Animals_IAP_Example.roter_panda", "de.JBCodes.Animals_IAP_Example.seeloewe", "de.JBCodes.Animals_IAP_Example.tiger", "de.JBCodes.Animals_IAP_Example.wolf"]
    
    public static let store = IAPHelper(productIds: AnimalsIAPExampleProducts.productIdentifiers)
}


//MARK: - IAPHelper

open class IAPHelper: NSObject {
    
    //MARK: - Properties
    
    private let productIdentifiers: Set<ProductIdentifier>
    
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    //MARK: - Initializer
    
    public init(productIds: Set<ProductIdentifier>) {
        
        productIdentifiers = productIds
        
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Bereits gekauft: \(productIdentifier)")
            } else {
                print("Nicht gekauft: \(productIdentifier)")
            }
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
}

//MARK: - StoreKit API

extension IAPHelper {
    
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        
        print("Kaufe \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

//MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print("Lade Produktliste...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Produkt gefunden: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        
        print("Laden der Produktliste fehlgeschlagen.")
        print("Fehler: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

//MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        
        print("Kauf abgeschlossen...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        
        print("Kauf fehlgeschlagen...")
        if let transactionError = transaction.error as NSError?,
           let localizedDescription = transaction.error?.localizedDescription,
           transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaktionsfehler: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("Kauf wiederherstellen... \(productIdentifier)")
        
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }
}
