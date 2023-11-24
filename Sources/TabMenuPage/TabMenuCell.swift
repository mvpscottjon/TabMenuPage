//
//  TabMenuCell.swift
//  TabMenu
//
//  Created by Seven Tsai on 2023/11/22.
//

import UIKit

final class TabMenuCell: UICollectionViewCell {
    
    private lazy var titleLabel = makeTitleLabel()
    private lazy var bottomLineView = makeBottomLineView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.bottomLineView.backgroundColor = self.isSelected ? .blue : .clear
                    self.layoutIfNeeded()
                }
            }
        }
    }
}

extension TabMenuCell {
    func update(withTitle title: String) {
        titleLabel.text = title
    }
}

private extension TabMenuCell {
    func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2.0)
        }
    }
}

private extension TabMenuCell {
    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }
    
    func makeBottomLineView() -> UIView {
        let view = UIView()
        return view
    }
}
