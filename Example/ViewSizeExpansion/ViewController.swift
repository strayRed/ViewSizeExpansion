//
//  ViewController.swift
//  ViewSizeExpansion
//
//  Created by strayRed on 01/30/2023.
//  Copyright (c) 2023 strayRed. All rights reserved.
//

import UIKit
import ViewSizeExpansion
import SnapKit

class ExpandableLabelView: UIView, NormalViewSizeExpandable {
    
    let constraintWidth: CGFloat
    
    let defaultLabelHeight: CGFloat = 50
    
    let update: (_ expandableLabelView: ExpandableLabelView, _ newHeight: CGFloat) -> ()
    
    let label: UILabel = .init()
    
    let imageIndicator = ImageExpansionIndicatorView(collapsedImage: UIImage.init(named: "arrow_collapsed")!, expandedImage: UIImage.init(named: "arrow_expanded")!)
    
    var expandableContainerViewLayoutType: UIView.LayoutSizeCaculatingType {
        .autoLayout(sizeConstraint: .width(constraintWidth), style: .compressed)
    }
    
    var expansionActivator: ExpansionActivator { imageIndicator }
    
    var containerViewDefaultHeight: CGFloat? {
        defaultLabelHeight + 8
    }
    
    init(constraintWidth: CGFloat, update: @escaping (_ expandableLabelView: ExpandableLabelView, _ newHeight: CGFloat) -> ()) {
        self.constraintWidth = constraintWidth
        self.update = update
        super.init(frame: .zero)
        self.label.numberOfLines = 0
        self.label.textColor = .gray
        self.addSubview(label)
        self.addSubview(imageIndicator)
        imageIndicator.backgroundColor = .white.withAlphaComponent(0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func expandableContainerViewSizeNeedUpdating(size: CGSize, isInitial: Bool) {
        update(self, size.height)
    }

    func layoutContainerViewSubviews(expansionState: ExpansionState) {
        label.snp.removeConstraints()
        imageIndicator.snp.removeConstraints()
        switch expansionState {
        case .expanded:
            label.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(5)
                make.trailing.equalToSuperview().offset(-8)
            }
            imageIndicator.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(20)
                make.bottom.equalToSuperview()
            }
        case .collapsed:
            label.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(8)
                make.height.lessThanOrEqualTo(defaultLabelHeight)
                make.trailing.bottom.equalToSuperview().offset(-8)
            }
            imageIndicator.snp.makeConstraints { make in
                make.leading.bottom.trailing.equalToSuperview()
                make.height.equalTo(20)
            }
        case .invalid:
            label.snp.makeConstraints { make in
                make.leading.top.equalToSuperview().offset(8)
                make.trailing.bottom.equalToSuperview().offset(-8)
            }
            imageIndicator.removeFromSuperview()
        }
    }
    
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let constraintWidth: CGFloat = view.bounds.width*(2/3)
        
        let expandableLabelView = ExpandableLabelView.init(constraintWidth: constraintWidth) { view, newHeight in
            // Do any additional update.
        }
        expandableLabelView.label.text = "This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message.This is a message."
        view.addSubview(expandableLabelView)
        expandableLabelView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.width.equalTo(constraintWidth)
        }
        expandableLabelView.setup(expansionState: .collapsed)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
