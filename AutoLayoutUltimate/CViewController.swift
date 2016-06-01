//
//  CViewController.swift
//  AutoLayoutUltimate
//
//  Created by 张延深 on 16/5/31.
//  Copyright © 2016年 宜信. All rights reserved.
//

import UIKit

class CViewController: UITableViewController {

    @IBOutlet weak var testLbl: UILabel!
    
    @IBOutlet weak var cell1: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testLbl.text = "我可以永远笑着扮演你的配角，在你的背后自己煎熬，如果你不想要想退出要趁早，我没有非要一起到老，我可以不问感觉继续为爱讨好，冷眼的看着你的骄傲，若有情太难了想别恋要趁早，就算迷恋你的拥抱，忘了就好"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.contentSizeCategoryDidChange(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // 这句话一定要设置，否则不能换行
        testLbl.preferredMaxLayoutWidth = CGRectGetWidth(testLbl.frame)
        
        cell1.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: cell1.bounds.size.height)
        
        cell1.setNeedsLayout()
        cell1.layoutIfNeeded()
        
        let height = cell1.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        
        return height + 1
    }
    
    // MARK: - event response
    
    func contentSizeCategoryDidChange(notification: NSNotificationCenter) {
        
        self.updateFont()
    }
    
    @IBAction func addText(sender: UIBarButtonItem) {
        
        testLbl.text?.appendContentsOf("+这是新加的String+")
        tableView.reloadData()
    }
    
    @IBAction func deleteText(sender: UIBarButtonItem) {
        
        if testLbl.text?.characters.count > 5 {
            let index = testLbl.text?.endIndex.advancedBy(-5)
            testLbl.text = testLbl.text?.substringToIndex(index!)
            tableView.reloadData()
        }
    }
    
    // MARK: - private methods
    
    private func updateFont() {
        
        testLbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    }
    
    // MARK: - deinit
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }

}
