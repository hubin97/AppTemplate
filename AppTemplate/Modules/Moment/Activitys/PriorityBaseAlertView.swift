//
//  PriorityBaseAlertView.swift
//  Momcozy
//
//  Created by hubin.h on 2025/7/11.
//  Copyright © 2025 路特创新. All rights reserved.

/**
 # 测试用例
 
 Array(0...3).forEach { idx in
     self.normalAlert(with: idx)
 }
 
 // 模拟稍后较高优先级弹窗入队
 DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
     Array(0...3).forEach { idx in
         self.highAlert(with: idx)
     }
 }
 
 // 模拟稍后更高优先级弹窗入队
 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
     Array(0...3).forEach { idx in
         self.higherAlert(with: idx)
     }
 }
 
 // 强制的
 DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
     Array(0...3).forEach { idx in
         self.forceAlert(with: idx)
     }
 }
 
 // 致命的
 DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
     Array(0...3).forEach { idx in
         self.fatalAlert(with: idx)
     }
 }
 
 // 强制的
 DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
     Array(0...3).forEach { idx in
         self.forceAlert(with: idx)
     }
 }
 
 // 模拟稍后更高优先级弹窗入队
 DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
     Array(0...3).forEach { idx in
         self.higherAlert(with: idx)
     }
 }
 
 // 强制的
 DispatchQueue.main.asyncAfter(deadline: .now() + 23) {
     Array(0...3).forEach { idx in
         self.forceAlert(with: idx)
     }
 }

func normalAlert(with idx: Int) {
 let normalAlert = PriorityBaseAlertView(priority: .normal, icon: nil, title: "普通: \(idx)", message: "普通消息")
 normalAlert.onStateChange = { state in
     print("NormalAlert state: \(state)")
 }
 normalAlert.addPrimaryAction(title: "确认") {
     print("NormalAlert primary tapped")
 }
 normalAlert.show()
}

func highAlert(with idx: Int) {
 let highAlert = PriorityBaseAlertView(priority: .high, icon: nil, title: "较高: \(idx)", message: "高优先级消息")
 highAlert.onStateChange = { state in
     print("highAlert state: \(state)")
 }
 highAlert.addPrimaryAction(title: "确认") {
     print("highAlert primary tapped")
 }
 highAlert.show()
}

func higherAlert(with idx: Int) {
 let higherAlert = PriorityBaseAlertView(priority: .higher, icon: nil, title: "更高: \(idx)", message: "更高优先级消息")
 higherAlert.onStateChange = { state in
     print("HigherAlert state: \(state)")
 }
 higherAlert.addPrimaryAction(title: "确认") {
     print("HigherAlert primary tapped")
 }
 higherAlert.show()
}

func forceAlert(with idx: Int) {
 let forceAlert = PriorityBaseAlertView(priority: .force, icon: nil, title: "强制: \(idx)", message: "强制打断消息")
 forceAlert.onStateChange = { state in
     print("ForceAlert state: \(state)")
 }
 forceAlert.addPrimaryAction(title: "确认") {
     print("forceAlert primary tapped")
 }
 forceAlert.show()
}

func fatalAlert(with idx: Int) {
 let fatalAlert = PriorityBaseAlertView(priority: .fatal, icon: nil, title: "致命: \(idx)", message: "致命的消息")
 fatalAlert.onStateChange = { state in
     print("fatalAlert state: \(state)")
 }
 fatalAlert.addPrimaryAction(title: "确认") {
     print("fatalAlert primary tapped")
 }
 fatalAlert.show()
}
 */

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: MomentPostAlertView
final class PriorityBaseAlertView: UIView, AlertContainable, AlertQueueable {
    
    // MARK: AlertQueueable
    var priority: AlertPriority = .normal
    
    // MARK: AlertContainable
    var isMaskEnabled: Bool = true
    var containerView: UIView {
        return internalContainerView
    }
    
    private lazy var internalContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.figma(.w500)(17)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.figma(.w400)(14)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = Fonts.figma(.w500)(16)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(color: Colors.thinBlack), for: .normal)
        button.setBorder(cornerRadius: 6, makeToBounds: true)
        button.addTarget(self, action: #selector(_onPrimaryButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = Fonts.figma(.w500)(16)
        button.setTitleColor(UIColor(hexStr: "#6A2B3A"), for: .normal)
        button.addTarget(self, action: #selector(_onSecondaryButtonTap), for: .touchUpInside)
        return button
    }()
    
    private var primaryTapAction: (() -> Void)?
    private var secondaryTapAction: (() -> Void)?
    
    // MARK: - Init
    required init(priority: AlertPriority = .normal, icon: UIImage?, title: String?, message: String?) {
        super.init(frame: .zero)
        self.priority = priority
        setupUI()
        configure(icon: icon, title: title, message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPrimaryAction(title: String, primaryTapAction: (() -> Void)?) {
        self.primaryTapAction = primaryTapAction
        self.primaryButton.setTitle(title, for: .normal)
    }
    
    func addSecondaryAction(title: String, secondaryTapAction: (() -> Void)?) {
        self.secondaryTapAction = secondaryTapAction
        self.secondaryButton.setTitle(title, for: .normal)
    }
}

// MARK: - Private Methods
extension PriorityBaseAlertView {
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        
        [iconView, titleLabel, messageLabel, primaryButton, secondaryButton].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            //make.width.lessThanOrEqualTo(300)
            make.leading.trailing.equalToSuperview().inset(kScaleW(24))
        }
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(48)
        }
        secondaryButton.snp.makeConstraints { make in
            make.top.equalTo(primaryButton.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func configure(icon: UIImage?, title: String?, message: String?) {
        iconView.image = icon
        titleLabel.text = title
        messageLabel.text = message
    }
}

// MARK: - Callbacks
extension PriorityBaseAlertView {
    
    @objc private func _onPrimaryButtonTap() {
        hide()
        primaryTapAction?()
    }
    
    @objc private func _onSecondaryButtonTap() {
        hide()
        secondaryTapAction?()
    }
}
