//
//  UIViewExtension.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation
import UIKit
import AVFoundation

extension UIView {
    
    /// SwifterSwift: Border width of view; also inspectable from Storyboard.
    @IBInspectable  var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// SwifterSwift: Border color of view; also inspectable from Storyboard.
    @IBInspectable  var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            layer.borderColor = color.cgColor
        }
    }
    
    /// SwifterSwift: Corner radius of view; also inspectable from Storyboard.
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
}


extension UITableView {
    func visibileCellIndexPath () -> IndexPath? {
        let visibleIndexPaths = self.indexPathsForVisibleRows ?? []
        
        var maxVisibleArea: CGFloat = 0.0
        var mostVisibleIndex : IndexPath?
        
        for indexPath in visibleIndexPaths {
            let cellRect = self.rectForRow(at: indexPath)
            let visibleCellRect = cellRect.intersection(self.bounds) // Get visibleCell frame cell rect is the cell which will check how much visible in tableview
            let visibleArea = visibleCellRect.height * visibleCellRect.width
            
            if visibleArea > maxVisibleArea {
                maxVisibleArea = visibleArea
                mostVisibleIndex = indexPath
            }
        }
        
        return mostVisibleIndex
    }
}
