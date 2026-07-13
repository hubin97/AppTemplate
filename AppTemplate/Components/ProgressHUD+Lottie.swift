//
//  ProgressHUD+Lottie.swift
//  AppTemplate
//
//  业务工程集成 Lottie 加载动画

import UIKit
import Lottie
import SnapKit
import AppStart

extension ProgressHUD {

    // MARK: - 简易默认

    /// 简易默认：仅 `LottieAnimationView` + `ProgressHUD.custom`，不依赖额外自定义容器
    static func showSimpleLottieLoading(
        named: String,
        interaction: Bool = true,
        size: CGFloat? = nil
    ) {
        let animationSize = size ?? ProgressHUD.mediaSize
        let lottieView = LottieAnimationView(name: named)
        lottieView.backgroundColor = .white
        lottieView.frame = CGRect(x: 0, y: 0, width: animationSize, height: animationSize)
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.play()
        ProgressHUD.custom(lottieView, interaction: interaction)
    }

    // MARK: - Momcozy 卡片

    /// Momcozy 设备页 Lottie Loading 样式：白底圆角卡片 + 可选文案（依赖 `LottieLoadingCardView`）
    static func showLottieLoading(
        named: String,
        message: String? = nil,
        interaction: Bool = true,
        lottieSize: CGSize = CGSize(width: 56, height: 56),
        cardWidth: CGFloat = 148
    ) {
        let card = LottieLoadingCardView(
            message: message,
            animationName: named,
            lottieSize: lottieSize,
            cardWidth: cardWidth
        )
        card.layoutIfNeeded()

        let cardSize = card.systemLayoutSizeFitting(
            CGSize(width: cardWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        card.frame = CGRect(origin: .zero, size: cardSize)
        card.play()

        presentCustomLottie(card, interaction: interaction, clearHUDBackground: true)
    }

    private static func presentCustomLottie(
        _ view: UIView,
        interaction: Bool,
        clearHUDBackground: Bool
    ) {
        if clearHUDBackground {
            let previousHUDColor = ProgressHUD.colorHUD
            ProgressHUD.colorHUD = .clear
            ProgressHUD.custom(view, interaction: interaction)
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    ProgressHUD.colorHUD = previousHUDColor
                }
            }
        } else {
            ProgressHUD.custom(view, interaction: interaction)
        }
    }
}

// MARK: - LottieLoadingCardView
private final class LottieLoadingCardView: UIView {

    private let animationName: String
    private let lottieSize: CGSize
    private let cardWidth: CGFloat

    private lazy var lottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: animationName)
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.figma(.w400)(14)
        label.textColor = Colors.thinBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init(message: String?, animationName: String, lottieSize: CGSize, cardWidth: CGFloat) {
        self.animationName = animationName
        self.lottieSize = lottieSize
        self.cardWidth = cardWidth
        super.init(frame: .zero)
        backgroundColor = .white
        setBorder(cornerRadius: 16, makeToBounds: true)
        messageLabel.text = message
        messageLabel.isHidden = message?.isEmpty != false
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(lottieView)
        addSubview(messageLabel)

        snp.makeConstraints { make in
            make.width.equalTo(cardWidth)
        }

        lottieView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(lottieSize)
        }

        if messageLabel.isHidden {
            lottieView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(24)
            }
        } else {
            messageLabel.snp.makeConstraints { make in
                make.top.equalTo(lottieView.snp.bottom).offset(14)
                make.leading.trailing.equalToSuperview().inset(12)
                make.bottom.equalToSuperview().inset(16)
            }
        }
    }

    func play() {
        lottieView.play()
    }

    func stop() {
        lottieView.stop()
    }
}
