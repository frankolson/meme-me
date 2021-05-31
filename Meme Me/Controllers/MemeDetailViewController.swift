//
//  MemeDetailViewController.swift
//  Meme Me
//
//  Created by Will Olson on 5/31/21.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    
    // MARK: Properties
    
    var meme: Meme?
    
    // MARK: Outlets

    @IBOutlet weak var memeImage: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        self.memeImage.image = meme?.memeImage
    }
}
