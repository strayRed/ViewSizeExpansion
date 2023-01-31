//
//  NormalViewSizeExpandable.swift
//  ViewExpandable
//
//  Created by strayRed on 2021/8/3.
//

import Foundation
import AssociatedObjectAccessible

fileprivate final class ExpandableSize {
    
    private var store: [AnyHashable: CGSize] = [:]
    
    func value(for state: ExpansionState) -> CGSize {
        store[state] ?? .zero
    }
    
    func set(value: CGSize, forState state: ExpansionState) {
        store[state] = value
    }
    
    init() { }
    
}

fileprivate struct NormalViewSizeExpansionContext {
    
    var expandableSize = ExpandableSize()
    var expansionState = ExpansionState.collapsed
    var isViewLayouted = false
    var isExpansionInvalid: Bool {
        expansionState == .invalid
    }
    
    var currentContainerViewSize: CGSize {
        set {
            expandableSize.set(value: newValue, forState: expansionState)
        }
        get {
            return expandableSize.value(for: expansionState)
        }
    }
}

private var viewSizeExpansionContextKey: Void?

public protocol NormalViewSizeExpandable: AnyObject, ViewSizeExpandable, AssociatedObjectAccessible {
    
    var expandableContainerViewLayoutType: UIView.LayoutSizeCaculatingType { get }
    
    func expandableContainerViewSizeNeedUpdating(size: CGSize, isInitial: Bool)
    
}

extension NormalViewSizeExpandable {
    
    private var context: NormalViewSizeExpansionContext {
        set  { setRetainedAssociatedObject(newValue, forKey: &viewSizeExpansionContextKey) }
        get { getAssociatedObject(forKey: &viewSizeExpansionContextKey, default: NormalViewSizeExpansionContext()) }
    }
    
    private func caculateExpandableSizeIfNeed() -> Bool {
        guard context.currentContainerViewSize.height == 0 || context.currentContainerViewSize.width == 0 else { return true }
        let checkInvalidResult = checkLayoutIsInvalid(layoutType: expandableContainerViewLayoutType)
        if checkInvalidResult.isInvalid {
            // Update context state.
            context.expansionState = .invalid
            // Update activator state.
            expansionActivator.expansionStateDidChanged(expansionState: .invalid)
            // Cache the size.
            context.currentContainerViewSize = checkInvalidResult.invalidLayoutSize
        }
        else {
            // Re-layout.
            layoutContainerViewSubviews(expansionState: context.expansionState)
            // Caculate the size.
            let size = expandableContainerView.caculateLayoutSize(type: expandableContainerViewLayoutType)
            context.currentContainerViewSize = size
        }
        
        #if DEBUG
        if context.currentContainerViewSize.height == 0 || context.currentContainerViewSize.width == 0  {
            print("⚠️ The height or width of \(self) will be assigned to 0. Please check your auto layout constraints in it.")
        }
        #endif
        return false
        
    }
    
    public func expandableContainerViewSizeNeedUpdating(size: CGSize, isInitial: Bool) { }
    
    /// Call this method to layout subviews and build up a connection between expansion indicator/activator and `containerView`.
    
    /// - Parameter expansionState: The inital expansion state.
    public func setup(expansionState: ExpansionState) {
        context = NormalViewSizeExpansionContext()
        setupInternal(expansionState: expansionState) { [weak self] expansionState in
            guard let self = self else { return }
            // Update context state.
            self.context.expansionState = expansionState
            let shouldRelayout = self.caculateExpandableSizeIfNeed()
            
            if shouldRelayout {
                self.layoutContainerViewSubviews(expansionState: expansionState)
            }
            // Additional update.
            self.expandableContainerViewSizeNeedUpdating(size: self.context.currentContainerViewSize, isInitial: !self.context.isViewLayouted)
            
            if !self.context.isViewLayouted {
                self.context.isViewLayouted = true
            }
        }
    }
}
