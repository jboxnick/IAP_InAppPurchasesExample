//
//  DetailViewController.swift
//  Animals IAP Example
//
//  Created by Julian Boxnick on 20.03.22.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView?
    
    var image: UIImage? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        imageView?.image = image
    }
}
