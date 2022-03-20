//
//  DetailViewController.swift
//  Animals IAP Example
//
//  Created by Julian Boxnick on 20.03.22.
//

import UIKit

class DetailViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView?
    
    //MARK: - Properties
    
    var image: UIImage? {
        didSet {
            setupViews()
        }
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    //MARK: - Setup Functions
    
    private func setupViews() {
        
        imageView?.contentMode = .scaleAspectFill
        imageView?.image = image
    }
}
