//
//  ElementCell.swift
//  SortViz
//
//  Created by Deszip on 14/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import UIKit

class ElementCell: UICollectionViewCell {

    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var valueViewHeightConstraint: NSLayoutConstraint!

    private var value: Int64 = 0
    private var maxValue: Int64 = 0
    
    func setValue(_ value: Int64, maxValue: Int64) {
        self.value = value
        self.maxValue = maxValue
        
        let valueViewHeight = (frame.size.height / CGFloat(maxValue)) * CGFloat(value)
        valueViewHeightConstraint.constant = valueViewHeight
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let valueViewHeight = (frame.size.height / CGFloat(maxValue)) * CGFloat(value)
        valueViewHeightConstraint.constant = valueViewHeight
    }

}
