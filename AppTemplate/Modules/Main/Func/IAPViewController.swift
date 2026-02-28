//
//  IAPViewController.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/1/8.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import StoreKit

// MARK: - Global Variables & Functions (if necessary)
struct IAPProduct {
    let id: String
    let title: String
    let description: String
    let price: String
    let product: Product
}

enum StoreError: Error {
    case failedVerification
    case purchaseFailed
}

// MARK: - Main Class
class IAPViewController: DefaultViewController {
    
    private var products: [Product] = []
    
    // 定义你的商品 IDs（来自 App Store Connect）
    let productIds: Set<String> = ["yoga.course.basic.chapter01", "yoga.course.advanced.chapter01"]
    
    // UI组件懒加载
    private lazy var purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("购买课程", for: .normal)
        button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("恢复购买", for: .normal)
        button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var successLabel: UILabel = {
        let label = UILabel()
        label.text = "购买成功！"
        label.textColor = .green
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.isHidden = true  // 初始隐藏
        return label
    }()
    
    override func setupLayout() {
        view.addSubview(purchaseButton)
        view.addSubview(restoreButton)
        view.addSubview(successLabel)
        
        purchaseButton.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        restoreButton.snp.makeConstraints { make in
            make.top.equalTo(purchaseButton.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(purchaseButton.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
    }
    
    override func bindViewModel() {
        Task {
            await fetchProducts()
        }
    }
}

// MARK: - Private Methods
extension IAPViewController {
    
    // 按钮点击事件
    @objc func purchaseButtonTapped() {
        // 调用沙盒内购功能
        guard let p = products.first else { return }
        Task {
            await self.purchaseProduct(p)
        }
    }
    
    @objc func restoreButtonTapped() {
        Task {
            await self.restorePurchases()
        }
    }
}

// MARK: - Callbacks
extension IAPViewController {
}

// MARK: - Utilities & Helpers
extension IAPViewController {
    
    // 拉取商品信息
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: productIds)
            // 处理商品信息
            print(products)
            self.products = products
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    // 商品购买
    func purchaseProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                // 处理购买成功后的逻辑
                await transaction.finish()
            case .userCancelled:
                print("User cancelled the purchase.")
            case .pending:
                print("Purchase is pending.")
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }
    
    // 结果购买
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.failedVerification
        }
    }

    // 交易成功后，你可以根据商品 productID 进行业务处理，比如解锁功能或内容。
    func handleTransaction(_ transaction: Transaction) async {
        iToast.makeToast("交易成功: \(transaction.productID)")
        if transaction.productID == "yoga.course.basic.chapter01" {
            //unlockBasicCourse()
            successLabel.isHidden = true
        } else if transaction.productID == "com.yourapp.course.advanced" {
            //unlockAdvancedCourse()
        }
    }

    // 恢复购买
    func restorePurchases() async {
        do {
            for await result in Transaction.currentEntitlements {
                let transaction = try checkVerified(result)
                await handleTransaction(transaction)
            }
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    // 监听交易状态更新
    // StoreKit 2 引入了 Transaction.updates，通过这个流你可以监听交易状态的变化。比如，当交易成功、失败或取消时，可以立即获取更新。
    func observeTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.handleTransaction(transaction)
                    // 交易完成后，你需要通过 finish() 方法通知 StoreKit，该交易已处理完成。
                    await transaction.finish()
                } catch {
                    print("Transaction failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Delegate & Data Source
extension IAPViewController {
}
