//
//  ExpansionIndicator.swift
//  ViewExpandable
//
//  Created by strayRed on 2021/8/3.
//
import AssociatedObjectAccessible

public protocol ExpansionIndicator: ExpansionActivator {
    var indicatorView: UIView { get }
}

extension ExpansionIndicator where Self: UIView {
    public var indicatorView: UIView { self }
}

private var tapEventDisposeBagKey: Void?

extension ExpansionIndicator {
    
    @inlinable public func toggleExpansionState() {
        self.expansionState.toggle()
    }
}

open class ImageExpansionIndicatorView: UIView, ExpansionIndicator {
    
    public let collapsedImage: UIImage
    
    public let expandedImage: UIImage
    
    public let imageView = UIImageView()
    
    open func expansionStateDidChanged(expansionState: ExpansionState) {
        switch expansionState {
        case .expanded: imageView.image = expandedImage
        case .collapsed: imageView.image = collapsedImage
        case .invalid: imageView.image = nil
        }
    }
    
    public init(collapsedImage: UIImage, expandedImage: UIImage) {
        self.collapsedImage = collapsedImage
        self.expandedImage = expandedImage
        imageView.contentMode = .center
        imageView.isUserInteractionEnabled = true
        super.init(frame: .zero)
        self.addSubview(imageView)
    }
    
    open override func layoutSubviews() {
        imageView.frame = bounds
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleExpansionState()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


