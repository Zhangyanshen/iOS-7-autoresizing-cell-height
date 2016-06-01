//
//  BViewController.swift
//  手写约束玩玩
//
//  Created by 张延深 on 16/5/26.
//  Copyright © 2016年 宜信. All rights reserved.
//

import UIKit

class BViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let cellID = "cell"
    private var tableView: UITableView?
    
    private var dataArray: NSMutableArray = NSMutableArray()
    
    private var offscreenCells: NSMutableDictionary = NSMutableDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化数据
        for i in 0..<20 {
            let model = YSModel()
            var title = "", content = ""
            let contentCount = arc4random() % 101 + 10
            let titleCount = arc4random() % 11 + 1
            for _ in 0..<titleCount {
                title.appendContentsOf("张")
            }
            for _ in 0..<contentCount {
                content.appendContentsOf("深")
            }
            model.title = "\(i):\(title)"
            model.content = content
            // content字符个数是3的倍数显示icon
            if contentCount % 3 == 0 {
                model.icon = "product_realization_btn"
                model.showDeleteBtn = false
            } else {
                model.icon = ""
                model.showDeleteBtn = true
            }
            dataArray.addObject(model)
        }
        // 初始化tableView
        self.initTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.contentSizeCategoryDidChange(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    // MARK: - event response
    
    func contentSizeCategoryDidChange(notification: NSNotification) {
        
        tableView?.reloadData()
    }
    
    // MARK: - private methods
    
    private func initTableView() {
        // 创建tableView
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView = tableView
        self.view.addSubview(tableView)
        
//        tableView.separatorStyle = .None
        
        // 注册cell
        tableView.registerClass(YSTableViewCell.self, forCellReuseIdentifier: cellID)
        // 解决iOS 7上导航栏被遮挡的问题
        self.edgesForExtendedLayout = .None
        // 不能选中
        tableView.allowsSelection = false
        
        // Setting the estimated row height prevents the table view from calling tableView:heightForRowAtIndexPath: for every row in the table on first load;
        // it will only be called as cells are about to scroll onscreen. This is a major performance optimization.
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
//        if #available(iOS 8.0, *) {
//            tableView.estimatedRowHeight = 200.0
//            tableView.rowHeight = UITableViewAutomaticDimension
//        } else {
//            tableView.estimatedRowHeight = UITableViewAutomaticDimension
//        }
        
        let viewDic: [String: AnyObject] = ["tableView": tableView]
        
        // 添加约束
        let constraints1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: NSLayoutFormatOptions.AlignAllTop, metrics: nil, views: viewDic)
        let constraints2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: viewDic)
        
        self.view.addConstraints(constraints1)
        self.view.addConstraints(constraints2)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! YSTableViewCell

        let model = dataArray[indexPath.row]
        cell.model = model as? YSModel
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var cell: YSTableViewCell? = offscreenCells.objectForKey(cellID) as? YSTableViewCell
        if cell == nil {
            cell = YSTableViewCell()
            offscreenCells.setValue(cell, forKey: cellID)
        }
        
        let model = dataArray[indexPath.row]
        cell!.model = model as? YSModel
        
        cell!.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell!.bounds))
        
        cell?.setNeedsLayout()
        cell?.layoutIfNeeded()
        
        return (cell!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height) + 1
    }

    // MARK: - deinit
    
    deinit {
        print("BViewController释放了！")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
