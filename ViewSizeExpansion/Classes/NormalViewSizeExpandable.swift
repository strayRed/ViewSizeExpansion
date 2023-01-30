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

public protocol NormalViewSizeExpandable: UIView, ViewSizeExpandable {
    
    var expandableContainerViewLayoutType: UIView.LayoutSizeCaculatingType { get }
    
    func expandableContainerViewSizeNeedUpdating(size: CGSize, isInitial: Bool)
    
}

extension NormalViewSizeExpandable {
    
    private var context: NormalViewSizeExpansionContext {
        set  { setRetainedAssociatedObject(newValue, forKey: &viewSizeExpansionContextKey) }
        get { getAssociatedObject(forKey: &viewSizeExpansionContextKey, default: NormalViewSizeExpansionContext()) }
    }
    
    private func caculateExpandableSizeIfNeed() {
        if context.currentContainerViewSize.height == 0 || context.currentContainerViewSize.width == 0 {
            self.layoutContainerViewSubviews(expansionState: context.expansionState)
            let size = expandableContainerView.caculateLayoutSize(type: expandableContainerViewLayoutType)
            if checkSizeIsInvalid(size) {
                context.expansionState = .invalid
                self.layoutContainerViewSubviews(expansionState: .invalid)
            }
            context.currentContainerViewSize = size
        }
        
        #if DEBUG
        
        if context.currentContainerViewSize.height == 0 || context.currentContainerViewSize.width == 0  {
            print("⚠️ The height or width of \(self) will be assigned to 0. Please check your auto layout constraints in it.")
        }
        
        #endif
        
    }
    
    /// Call this method to layout subviews and build up a connection between expansion indicator/activator and `containerView`.
    
    /// - Parameter expansionState: The inital expansion state.
    public func setup(expansionState: ExpansionState) {
        context = NormalViewSizeExpansionContext()
        setupInternal(expansionState: expansionState) { [weak self] expansionState in
            guard let self = self else { return }
            /// the expansion state has been changed.
            self.context.expansionState = expansionState
            self.caculateExpandableSizeIfNeed()
             
            func updateContainerViewSize() {
                self.expandableContainerViewSizeNeedUpdating(size: self.context.currentContainerViewSize, isInitial: !self.context.isViewLayouted)
            }
            if self.context.isViewLayouted && !self.context.isExpansionInvalid {
                self.layoutContainerViewSubviews(expansionState: expansionState)
                updateContainerViewSize()
            }
            else {
                updateContainerViewSize()
                self.context.isViewLayouted = true
            }
        }
    }
}
