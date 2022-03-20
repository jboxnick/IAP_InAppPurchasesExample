//
//  AnimalsIAPExampleProducts.swift
//  Animals IAP Example
//
//  Created by Julian Boxnick on 20.03.22.
//

import Foundation

public struct AnimalsIAPExampleProducts {
    
    //MARK: - Properties
    
    private static let productIdentifiers: Set<ProductIdentifier> = ["de.JBCodes.RazeFaces.swiftshopping"]
    
    public static let store = IAPHelper(productIds: AnimalsIAPExampleProducts.productIdentifiers)
}

//MARK: - Helper Functions

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
