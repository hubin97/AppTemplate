//
//  DefaultTableViewCell.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/12.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class DefaultTableViewCell: TableViewCell, Themeable {

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = view.font.withSize(16)
        return view
    }()

    lazy var detailLabel: UILabel = {
        let view = UILabel()
        view.font = view.font.withSize(14)
        return view
    }()

    lazy var stackView: UIStackView = {
        let subviews: [UIView] = []
        let view = UIStackView(arrangedSubviews: subviews)
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        return view
    }()
    
    lazy var textsStackView: UIStackView = {
        let views: [UIView] = [self.titleLabel, self.detailLabel]
        let view = UIStackView(arrangedSubviews: views)
        view.spacing = 2
        return view
    }()

    private let inset: CGFloat = 16
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(textsStackView)
        
        stackView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: inset/2, left: inset, bottom: inset/2, right: 0))
            //make.height.greaterThanOrEqualTo(44)
        })
        
        withThemeUpdates { (self, theme) in
            // print("withThemeUpdates...\(theme)")
            self.backgroundColor = theme.backgroundColor
            //self.arrowView.image = theme.type == .light ? Asset.iconRightBlack.image.adaptRTL: Asset.iconRightWhite.image.adaptRTL
            self.titleLabel.textColor = theme.textColor
            self.detailLabel.textColor = theme.textColor
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bind(to viewModel: TableViewCellViewModel) {
        super.bind(to: viewModel)
        guard let viewModel = viewModel as? DefaultTableViewCellViewModel else { return }
        viewModel.title.asDriver().drive(titleLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.title.map({ $0 ?? "" }).map({ $0.isEmpty }).asDriver(onErrorJustReturn: true).drive(titleLabel.rx.isHidden).disposed(by: rx.disposeBag)

        viewModel.detail.asDriver().drive(detailLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.detail.map({ $0 ?? "" }).map({ $0.isEmpty }).asDriver(onErrorJustReturn: true).drive(detailLabel.rx.isHidden).disposed(by: rx.disposeBag)
    }
}
// MARK: - Private Methods
extension DefaultTableViewCell {
}

// MARK: - Callbacks
extension DefaultTableViewCell {
}

// MARK: - Utilities & Helpers
extension DefaultTableViewCell {
}

// MARK: - Delegate & Data Source
extension DefaultTableViewCell {
}
