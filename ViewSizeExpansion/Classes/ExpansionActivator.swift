//
//  ExpansionActivator.swift
//  ViewExpandable
//
//  Created by strayRed on 2021/8/3.
//

import AssociatedObjectAccessible

/// The activator to activate the expansion action.
public protocol ExpansionActivator: AnyObject, AssociatedObjectAccessible {
    
    /// This method will be called after the `expansionState` property has been changed.
    func expansionStateDidChanged(expansionState: ExpansionState)
    
}

extension ExpansionActivator {
    func expansionStateDidChanged(isExpanded: Bool) { }
}

var expansionStateKey: Void?
var changeExpansionStateInternalKey: Void?
extension ExpansionActivator {
    /// assgin new value to this property to update expansion state.
    public var expansionState: ExpansionState {
        set {
            setRetainedAssociatedObject(newValue, forKey: &expansionStateKey)
            changeExpansionStateInternal?(newValue)
            expansionStateDidChanged(expansionState: newValue)
        }
        get {
            getAssociatedObject(forKey: &expansionStateKey, default: ExpansionState.collapsed)
        }
    }
    
    var changeExpansionStateInternal: ((ExpansionState) -> ())? {
        set {
            setRetainedAssociatedObject(newValue, forKey: &changeExpansionStateInternalKey)
        }
        get {
            getAssociatedObject(forKey: &changeExpansionStateInternalKey, default: nil)
        }
    }
 }
