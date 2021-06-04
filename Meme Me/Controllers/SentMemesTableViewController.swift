//
//  SentMemesTableViewController.swift
//  Meme Me
//
//  Created by Will Olson on 5/31/21.
//

import Foundation
import UIKit

class SentMemesTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var allMemes: [Meme] {
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    
    // MARK: Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        // This only works if the segue is presented with a "Fullscreen" presentation
        // source: https://stackoverflow.com/a/51089181/3347828
        self.tableView.reloadData()
    }
    
    // MARK: Table Data Source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMemes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memeTableCell")!
        let meme = self.allMemes[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        cell.textLabel?.text = meme.fullText
        cell.imageView?.image = meme.memeImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.allMemes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}
