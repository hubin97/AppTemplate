////
////  WebPImageDecoder.swift
////  Momcozy
////
////  Created by hubin.h on 2025/8/11.
////  Copyright © 2025 路特创新. All rights reserved.
//
import UIKit
import Kingfisher
import KingfisherWebP
//import SVGKit

// MARK: - Global Variables & Functions (if necessary)

extension UIImage {
    
    /**
     1. Pod引入
     pod 'Kingfisher', '~> 8.0'
     pod 'KingfisherWebP'#, '~> 1.7.0'

     2. 全局注册 WebP 解码器
     KingfisherManager.shared.defaultOptions += [
       .processor(WebPProcessor.default),
       .cacheSerializer(WebPSerializer.default)
     ]
     
     3. 使用 Kingfisher的 AnimatedImageView当容器
     AnimatedImageView(image: UIImage.webp(named: "icon_webp_gift_popup"))
     */
    /// 加载本地 WebP 图片（无需写扩展名）
    static func webp(named name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "webp"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return WebPProcessor.default.process(item: .data(data), options: KingfisherParsedOptionsInfo([]))
    }
}

//struct SVGProcessor: ImageProcessor {

