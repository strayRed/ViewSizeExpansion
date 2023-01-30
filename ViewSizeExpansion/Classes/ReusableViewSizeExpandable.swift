//
//  CellSizeExpandable.swift
//  ViewExpandable
//
//  Created by strayRed on 2021/9/16.
//

import Foundation

public protocol ReusableViewSizeExpandable: ViewSizeExpandable { }

extension ReusableViewSizeExpandable {
    
    private func _setupReusableViewExpandableExpansion(state: ExpansionState, sizeConstraint: UIView.LayoutSizeConstraint, changed: @escaping (ExpansionState) -> ()) {
        setupInternal(expansionState: state) { state in
            changed(state)
            layoutContainerViewSubviews(expansionState: state)
            if state != .invalid {
                if checkLayoutIsInvalid(layoutType: .autoLayout(sizeConstraint: sizeConstraint, style: .compressed)) {
                    layoutContainerViewSubviews(expansionState: .invalid)
                    expansionActivator.expansionState = .invalid
                }
            }
        }
    }
    
    public func setupTableViewItemExpansion(state: ExpansionState, tableViewWidth: CGFloat, changed: @escaping (ExpansionState) -> ()) {
        _setupReusableViewExpandableExpansion(state: state, sizeConstraint: .width(tableViewItemContentWidth(superWidth: tableViewWidth) ?? tableViewWidth), changed: changed)
    }
    
    public func setupCollectionViewItemExpansion(state: ExpansionState, sizeConstraint: UIView.LayoutSizeConstraint, changed: @escaping (ExpansionState) -> ()) {
        _setupReusableViewExpandableExpansion(state: state, sizeConstraint: sizeConstraint, changed: changed)
    }
}

extension ReusableViewSizeExpandable {
    
    private func tableViewItemContentWidth(superWidth: CGFloat) -> CGFloat? {
        if let cell = expandableContainerView as? UITableViewCell {
            return cell.makeSystemContentViewWidth(tableViewWidth: superWidth)
        }
        if self is UITableViewHeaderFooterView {
            return superWidth
        }
        return nil
    }
}

extension UITableViewCell {
    fileprivate static let systemAccessoryWidths: [UITableViewCell.AccessoryType: CGFloat] = [.none: 0, .disclosureIndicator: 34, .detailDisclosureButton: 68, .checkmark: 40, .detailButton: 48]
}

extension UITableViewCell {
    fileprivate func makeSystemContentViewWidth(tableViewWidth: CGFloat) -> CGFloat {
        var contentViewWidth = tableViewWidth
        // the system view width
        var rightSystemViewsWidth: CGFloat = 0
        
        if let indexClass = NSClassFromString("UIKit.UITableViewIndex") {
            for view in subviews {
                if view.isKind(of: indexClass) {
                    rightSystemViewsWidth = view.frame.width; break
                }
            }
        }
        
        if let accessoryView = accessoryView {
            rightSystemViewsWidth += 16 + accessoryView.frame.width
        }
        else {
            rightSystemViewsWidth += UITableViewCell.systemAccessoryWidths[accessoryType]!
        }
        
        if UIScreen.main.scale >= 3.0 && UIScreen.main.bounds.width >= 414 {
            rightSystemViewsWidth += 4
        }
        
        contentViewWidth -= rightSystemViewsWidth
        
        return contentViewWidth
    }
    
}
