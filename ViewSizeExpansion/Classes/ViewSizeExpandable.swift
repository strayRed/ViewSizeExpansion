//
//  ViewSizeExpandable.swift
//  ViewExpandable
//
//  Created by strayRed on 2021/8/3.
//

import Foundation
import AssociatedObjectAccessible
import ViewSizeCalculation

public enum ExpansionState: String, Hashable {
    case expanded
    case collapsed
    case invalid
    
    mutating public func toggle() {
        if self == .expanded { self = .collapsed }
        else if self == .collapsed {  self  = .expanded}
    }
}

public protocol ViewSizeExpandable: AssociatedObjectAccessible {
    
    var expandableContainerView: UIView { get }
    
    var expansionActivator: ExpansionActivator { get }
    
    var containerViewDefaultWidth: CGFloat? { get }
    
    var containerViewDefaultHeight: CGFloat? { get }
    
    func layoutContainerViewSubviews(expansionState: ExpansionState)

}

extension ViewSizeExpandable {
    public var containerViewDefaultWidth: CGFloat? { nil }
    public var containerViewDefaultHeight: CGFloat? { nil }
}


extension ViewSizeExpandable {
    func setupInternal(expansionState: ExpansionState, changed: @escaping (ExpansionState) -> ()) {
        expansionActivator.changeExpansionStateInternal = changed
        expansionActivator.expansionState = expansionState
    }
}

extension ViewSizeExpandable where Self: UIView {
    public var expandableContainerView: UIView { self }
}

extension ViewSizeExpandable {
    
    func checkSizeIsInvalid(_ size: CGSize) -> Bool {
        let defaultSize = CGSize(width: containerViewDefaultWidth ?? size.width, height: containerViewDefaultHeight ?? size.height)
        let widthFlag = size.width < defaultSize.width && defaultSize.width != 0
        let heightFlag = size.height < defaultSize.height && defaultSize.height != 0
        return widthFlag || heightFlag
    }
    
    func checkLayoutIsInvalid(layoutType: UIView.LayoutSizeCaculatingType) -> Bool {
        if containerViewDefaultWidth == nil && containerViewDefaultHeight == nil { return false }
        let caculatedSize = expandableContainerView.caculateLayoutSize(type: layoutType)
        return checkSizeIsInvalid(caculatedSize)
    }
}

