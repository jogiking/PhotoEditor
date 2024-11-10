//
//  EditPhotoCollectionViewCell.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

import SnapKit

final class EditPhotoCollectionViewCell: UICollectionViewCell {
    
    // 이미지 뷰만 있는 셀
    private let emojiImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiImageView)
        setupLayouts()
        setupStyles()
    }
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        emojiImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        emojiImageView.contentMode = .scaleAspectFit
    }
    
    private func setupStyles() {
        emojiImageView.layer.cornerRadius = 4
        emojiImageView.layer.masksToBounds = true
    }
    
    func configure(with image: UIImage?) {
        emojiImageView.image = image
        updateAppearance()
    }
    
    private func updateAppearance() {
        emojiImageView.alpha = isSelected ? 0.5 : 1
    }
}
