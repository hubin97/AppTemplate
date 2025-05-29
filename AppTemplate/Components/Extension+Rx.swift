//
//  Extension+Rx.swift
//  Momcozy
//
//  Created by hubin.h on 2024/5/27.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
import RxSwift
import PromiseKit
import Kingfisher

extension Reactive where Base: UIControl {
    
    /// Bindable sink for `enabled` property.
    public var isEnabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = value
        }
    }
    
    /// Bindable sink for `selected` property.
    public var isSelected: Binder<Bool> {
        return Binder(self.base) { control, selected in
            control.isSelected = selected
        }
    }
}

// Kingfisher
extension Reactive where Base: UIImageView {

    @MainActor
    public var imageURL: Binder<URL?> {
        return self.imageURL(withPlaceholder: nil)
    }

    @MainActor
    public func imageURL(withPlaceholder placeholderImage: UIImage?, options: KingfisherOptionsInfo? = []) -> Binder<URL?> {
        return Binder(self.base, binding: { (imageView, url) in
            imageView.kf.setImage(with: url,
                                  placeholder: placeholderImage,
                                  options: options,
                                  progressBlock: nil,
                                  completionHandler: nil)
        })
    }
}

extension ImageCache: @retroactive ReactiveCompatible {}

extension Reactive where Base: ImageCache {

    func retrieveCacheSize() -> Observable<Int> {
        return Single.create { single in
            self.base.calculateDiskStorageSize { (result) in
                do {
                    single(.success(Int(try result.get())))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create { }
        }.asObservable()
    }

    public func clearCache() -> Observable<Void> {
        return Single.create { single in
            self.base.clearMemoryCache()
            self.base.clearDiskCache(completion: {
                single(.success(()))
            })
            return Disposables.create { }
        }.asObservable()
    }
}

// 扩展 PromiseKit 的 Promise
extension Promise {
    
    // 将 Promise 转换为 Observable
    func asObservable() -> Observable<T> {
        return Observable.create { observer in
            self.done { value in
                observer.onNext(value)
                observer.onCompleted()
            }.catch { error in
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
}
