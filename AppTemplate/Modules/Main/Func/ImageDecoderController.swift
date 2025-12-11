//
//  ImageDecoderController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/9/25.
//  Copyright © 2025 路特创新. All rights reserved.

import Foundation
import Kingfisher
import AppStart

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class ImageDecoderController: ViewController {
    
    lazy var webPView: AnimatedImageView = {
        let view = AnimatedImageView(image: UIImage.webp(named: "icon_webp_gift_popup"))
        view.contentMode = .scaleAspectFit
        view.autoPlayAnimatedImage = false
        view.repeatCount = .once
        return view
    }()

    override func setupLayout() {
        view.addSubview(webPView)

        webPView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.width.height.equalTo(kScaleW(320))
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: - Private Methods
extension ImageDecoderController {
    
    func show(duration: TimeInterval, finishBlock: (() -> Void)? = nil) {
        self.webPView.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.webPView.stopAnimating()
            finishBlock?()
        }
    }
}

// MARK: - Callbacks
extension ImageDecoderController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        show(duration: 2)
    }
}

// MARK: - Utilities & Helpers
extension ImageDecoderController {
}

// MARK: - Delegate & Data Source
extension ImageDecoderController {
}
