//
//  StickerImageView.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

import SnapKit
import Then

final class StickerImageView: UIView {
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    let handleView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = true
    }
    private let handleImageView = UIImageView().then {
        $0.image = UIImage.loadAsset(named: "icon_handle")
        $0.contentMode = .scaleAspectFit
    }
    let deleteView = UIView().then {
        $0.backgroundColor = "333333".stringToColor
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = true
    }
    private let deleteImageView = UIImageView().then {
        $0.image = UIImage.loadAsset(named: "icon_close10")
        $0.contentMode = .scaleAspectFit
    }
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                handleView.isHidden = false
                deleteView.isHidden = false
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.isUserInteractionEnabled = true
            } else {
                handleView.isHidden = true
                deleteView.isHidden = true
                imageView.layer.borderWidth = 0
            }
        }
    }
    
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
        addSubview(imageView)
        addSubview(handleView)
        handleView.addSubview(handleImageView)
        addSubview(deleteView)
        deleteView.addSubview(deleteImageView)
    }

    private func setupLayouts() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        deleteView.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.top.trailing.equalToSuperview()
        }
        deleteImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        handleView.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.trailing.bottom.equalToSuperview()
        }
        handleImageView.snp.makeConstraints {
            $0.size.equalTo(13)
            $0.center.equalToSuperview()
        }
    }

    private func setupStyles() {
        // test
        backgroundColor = .clear
        imageView.image = UIImage(systemName: "apple.logo")
    }

    
}
