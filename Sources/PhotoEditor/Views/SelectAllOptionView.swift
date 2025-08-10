//
//  SelectAllOptionView.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

import SnapKit

final class SelectAllOptionView: UIView {
    let openEmojiButton = UIButton()
    let openCanvasButton = UIButton()
    let verticalLineView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupLayouts()
        setupStyles()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(openEmojiButton)
        addSubview(openCanvasButton)
        addSubview(verticalLineView)
    }
    
    private func setupLayouts() {
        openEmojiButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        openCanvasButton.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        verticalLineView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(1)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupStyles() {
        backgroundColor = .black
        verticalLineView.backgroundColor = "333333".stringToColor
        openEmojiButton.setImage(UIImage(named: "icon_emoji", in: Bundle.module, compatibleWith: nil), for: .normal)
        openCanvasButton.setImage(UIImage(named: "icon_pencil", in: Bundle.module, compatibleWith: nil), for: .normal)
        self.addBorder([.top, .bottom], color: "333333".stringToColor, width: 1)
    }
}
