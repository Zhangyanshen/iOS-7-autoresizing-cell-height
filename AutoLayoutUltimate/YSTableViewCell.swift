//
//  YSTableViewCell.swift
//  手写约束玩玩
//
//  Created by 张延深 on 16/5/26.
//  Copyright © 2016年 宜信. All rights reserved.
//

/*
 ## Parenthetical Discussion of Constraint Errors
 ## Due to the Notorious "UIView-Encapsulated-Layout-Height" Constraint
 
 The constraints below allow you to configure the cell to add an additional requirement of
 a minimum height of 50, to cell, its contentview, or the label. This is in order to simulate
 the behavior of other cell designs, which have a height greater than 44 on initialization.
 
 Why is this interesting? It is interesting because such cells will sometimes start out
 in conflict with temporary UIKit constraints that set the cell to the default height of 44.
 
 When a UITableView using auto-sizing logic first runs, it initializes
 the cell, calls `tableView(_:cellForRowAtIndexPath:)` in order to populate the cell with content,
 and then calls the cell's
 `systemLayoutSizeFittingSize(:withHorizontalFittingPriority:verticalFittingPriority:)`
 in order to allow the cell to express its desired height given the width of the table view.
 
 But at the start of this call, the UITableViewCell begins with constraints for its
 default width (the screen width) and height (44 points!). This latter constraint is called
 `UIView-Encapsulated-Layout-Height`. Sometimes it appears on the cell, sometimes on the
 contentView. I don't know what rules decides this. If the constraints you have defined on the
 cell are incompiatble with this constraint requiring height==44, then the normal call to
 `systemLayoutSizeFittingSize(:withHorizontalFittingPriority:verticalFittingPriority:)` will emit
 error messages into the console regarding unsatisfiable constraints.
 
 However, these errors are _transient_. On its own, the UITV will later use the value that AL
 calculates for your cell's desired height (as revealed via
 the call to `systemLayoutSizeFittingSize(:withHorizontalFittingPriority:verticalFittingPriority:)`)
 and then reset the `UIView-Encapsulated-Layout-Height` to a value that is compatible with
 your cell's constraints and contents.
 
 ### CONCLUSION
 
 So what?
 
 The conclusion is, to avoid seeing these spurious warnings messages, you should configure your
 cell's constraints so that they are compatible with it having a required height of 44. For
 instance, you could reduce to 999 the priority of the spacer constraint connecting the bottom of
 the contentView to your bottom-most subview within the contentView. This allows that view to
 poke out beyond the bottom of your contentView, and makes a transient constraint that
 contentView.height==44 satisfiable.
 
 ### FINDINGS SUMMARY:
 
 1. height44 constraint invisible outside call to systemLayoutSizeFittingSize(...)
 2. height44 constraint is initalled on the cell not the contentView (in _this_ example...)
 3. non44 constraint on cell => unsatisfiabilility warning
 4. non44 constraint on cell.contentView => no unsatisfiability warning
 5. non44 constraint on cell.contentView.subviews => no unsatisfiability warning
 
 ### UNANSWERED QUESTIONS:
 
 1. How does UIKit decide where to put this spurious, transient constraint?
 2. If the `UIView-Encapsulated-Layout-Height` constraint starts out on the contentView, then how
 does `systemLayoutSizeFittingSize(:withHorizontalFittingPriority:verticalFittingPriority:)`
 determine what height the contentView would want to be in the absence of this constraint?
 3. Why is this so complicated?
*/

import UIKit
//import SnapKit

class YSTableViewCell: UITableViewCell {
    
    // MARK: - private property
 
    private var didSetupConstraints: Bool = false
 
    private var titleLbl: UILabel = {
        let titleLbl = UILabel()
        titleLbl.backgroundColor = UIColor.greenColor()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        return titleLbl
    }()
    
    private var icon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    private var contentLbl: UILabel = {
        let contentLbl = UILabel()
        contentLbl.backgroundColor = UIColor.yellowColor()
        contentLbl.numberOfLines = 0
        contentLbl.translatesAutoresizingMaskIntoConstraints = false
        return contentLbl
    }()
    
    private var deleteBtn: UIButton = {
        let deleteBtn = UIButton(type: UIButtonType.System)
        deleteBtn.backgroundColor = UIColor.redColor()
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.setTitle("Delete", forState: UIControlState.Normal)
        return deleteBtn
    }()
    
    private var contentBottomConstraint: NSLayoutConstraint?
    private var deleteBtnBottomConstraint: NSLayoutConstraint?
    
    // MARK: - public property
    
    var model: YSModel? {
        didSet {
            titleLbl.text = model?.title
            contentLbl.text = model?.content
            if model?.icon != "" {
                icon.hidden = false
                icon.image = UIImage(named: (model?.icon)!)
            } else {
                icon.hidden = true
            }
            if model?.showDeleteBtn == true {
                deleteBtn.hidden = false
            } else {
                deleteBtn.hidden = true
            }
            // 更新字体
            self.updateFont()
            // 更新约束
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
        }
    }
    
    private var viewDic: [String: AnyObject] = [:]
    
    // MARK: - init methods
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 添加view
        self.addAllView()
        // 初始化viewDic
        self.viewDic = ["titleLbl": titleLbl, "icon": icon, "contentLbl": contentLbl, "deleteBtn": deleteBtn]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override methods
    
    override func updateConstraints() {
        
        if didSetupConstraints == false {
            self.addAllConstraints()
//            self.addAllConstraintsWithVFL()
            didSetupConstraints = true
        }
        if model?.showDeleteBtn == false {
            self.contentView.removeConstraint(self.deleteBtnBottomConstraint!)
            self.contentView.addConstraint(self.contentBottomConstraint!)
        } else {
            self.contentView.removeConstraint(self.contentBottomConstraint!)
            self.contentView.addConstraint(self.deleteBtnBottomConstraint!)
        }
        // 放在该方法的最后
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        // 放在最开头
        super.layoutSubviews()
        // 确保控件的frame已经有了
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        // 不设置这个换行会有问题
        contentLbl.preferredMaxLayoutWidth = CGRectGetWidth(contentLbl.frame)
    }
    
    // MARK: - private methods
    
    private func addAllView() {
        
        self.contentView.addSubview(titleLbl)
        self.contentView.addSubview(icon)
        self.contentView.addSubview(contentLbl)
        self.contentView.addSubview(deleteBtn)
    }
    
    // 使用SnapKit添加约束
//    private func addAllConstraintsWithSnapKit() {
//        // titleLbl
//        titleLbl.snp_makeConstraints { (make) in
//            make.top.equalTo(self.contentView.snp_top).offset(10.0)
//            make.left.equalTo(self.contentView.snp_left).offset(15.0)
//            make.width.lessThanOrEqualTo(200.0)
//        }
//        // icon
//        icon.snp_makeConstraints { (make) in
//            make.left.equalTo(titleLbl.snp_right).offset(10.0)
//            make.centerY.equalTo(titleLbl.snp_centerY)
//        }
//        // contentLbl
//        contentLbl.snp_makeConstraints { (make) in
//            make.top.equalTo(titleLbl.snp_bottom).offset(10.0)
//            make.left.equalTo(titleLbl.snp_left)
//            make.right.equalTo(self.contentView.snp_right).offset(-8.0)
//            make.bottom.equalTo(deleteBtn.snp_top).offset(-10.0)
//        }
//        // deleteBtn
//        deleteBtn.snp_makeConstraints { (make) in
//            make.right.equalTo(contentLbl)
//            make.bottom.equalTo(self.contentView).offset(-8.0)
//        }
//    }
    
    // 使用VFL添加约束
    private func addAllConstraintsWithVFL() {
        
        let constraints1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[titleLbl(<=200)]-10-[icon]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewDic)
        let constraints2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[titleLbl]-10-[contentLbl]", options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: viewDic)
        
        let constraints3 = NSLayoutConstraint.constraintsWithVisualFormat("H:[deleteBtn]|", options: NSLayoutFormatOptions.AlignAllBottom, metrics: nil, views: viewDic)
        let constraints4 = NSLayoutConstraint.constraintsWithVisualFormat("V:[contentLbl]-[deleteBtn]-|", options: NSLayoutFormatOptions.AlignAllTrailing, metrics: nil, views: viewDic)
        
        self.contentView.addConstraints(constraints1)
        self.contentView.addConstraints(constraints2)
        
        self.contentView.addConstraints(constraints3)
        self.contentView.addConstraints(constraints4)
    }
    
    // 不使用VFL添加约束
    private func addAllConstraints() {
        // titleLbl
        let titleLblConstraint1 = NSLayoutConstraint(item: titleLbl, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let titleLblConstraint2 = NSLayoutConstraint(item: titleLbl, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 15.0)
        let titleLblConstraint3 = NSLayoutConstraint(item: titleLbl, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: 200.0)
        // icon
        let iconConstraint1 = NSLayoutConstraint(item: icon, attribute: .Left, relatedBy: .Equal, toItem: titleLbl, attribute: .Right, multiplier: 1.0, constant: 10.0)
        let iconConstraint2 = NSLayoutConstraint(item: icon, attribute: .CenterY, relatedBy: .Equal, toItem: titleLbl, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        // contentLbl
        let contentLblConstraint1 = NSLayoutConstraint(item: contentLbl, attribute: .Top, relatedBy: .Equal, toItem: titleLbl, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let contentLblConstraint2 = NSLayoutConstraint(item: contentLbl, attribute: .Left, relatedBy: .Equal, toItem: titleLbl, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let contentLblConstraint3 = NSLayoutConstraint(item: contentLbl, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: -8.0)
        
        // 1.将约束值减小，解决臭名昭著的'UIView-Encapsulated-Layout-Width'约束冲突问题
        // 2.优先级只能在初始化时设置，如果之后设置的话会crash
        // 3.优先级低于UILayoutPriorityRequired的约束是可选的(optional)
        contentLblConstraint3.priority = 999.0
        
        let contentLblConstraint4 = NSLayoutConstraint(item: contentLbl, attribute: .Bottom, relatedBy: .Equal, toItem: deleteBtn, attribute: .Top, multiplier: 1.0, constant: 0.0)
        // 默认不安装
        let contentLblConstraint5 = NSLayoutConstraint(item: contentLbl, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.contentBottomConstraint = contentLblConstraint5
        // deleteBtn
        let deleteBtnConstraint1 = NSLayoutConstraint(item: deleteBtn, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: -8.0)
        // 默认安装
        let deleteBtnConstraint2 = NSLayoutConstraint(item: deleteBtn, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.deleteBtnBottomConstraint = deleteBtnConstraint2
        
        self.contentView.addConstraint(titleLblConstraint1)
        self.contentView.addConstraint(titleLblConstraint2)
        titleLbl.addConstraint(titleLblConstraint3)
        
        self.contentView.addConstraint(iconConstraint1)
        self.contentView.addConstraint(iconConstraint2)
        
        self.contentView.addConstraint(contentLblConstraint1)
        self.contentView.addConstraint(contentLblConstraint2)
        self.contentView.addConstraint(contentLblConstraint3)
        self.contentView.addConstraint(contentLblConstraint4)
        
        self.contentView.addConstraint(deleteBtnConstraint1)
        self.contentView.addConstraint(deleteBtnConstraint2)
    }
    
    // 更新字体
    func updateFont() {
        
        titleLbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        contentLbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }

}
