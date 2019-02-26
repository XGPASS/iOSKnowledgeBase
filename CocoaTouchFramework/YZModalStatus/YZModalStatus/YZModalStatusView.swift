//
//  YZModalStatusView.swift
//  YZModalStatus
//
//  Created by linyongzhi on 2018/4/12.
//  Copyright © 2018年 linyongzhi. All rights reserved.
//

import UIKit

public class YZModalStatusView: UIView {
    
    @IBOutlet private weak var statusImageView: UIImageView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var subheadLabel: UILabel!
    
    let nibName = "YZModalStatusView";
    var contentView: UIView!
    var timer: Timer?
    
    // MARK: Set Up View
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(3), target: self, selector: #selector(self.removeSelf), userInfo: nil, repeats: false)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutIfNeeded()
        self.contentView.layer.masksToBounds = true
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 10
    }
    
    public func set(image: UIImage) {
        self.statusImageView.image = image
    }
    
    public func set(headline text: String) {
        self.headlineLabel.text = text
    }
    
    public func set(subheading text: String) {
        self.subheadLabel.text = text
    }
    
    private func setUpView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.nibName, bundle: bundle)
        self.contentView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        addSubview(contentView)
        
        contentView.center = self.center
        contentView.autoresizingMask = []
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        headlineLabel.text = ""
        subheadLabel.text = ""
    }
    
    @objc private func removeSelf() {
        self.removeFromSuperview()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension YZModalStatusView: YZStatusProtocol {
    public func setImage(_ image: UIImage!) {
        set(image: image)
    }
    
    public func setHeadline(_ headline: String!) {
        set(headline: headline)
    }
}
