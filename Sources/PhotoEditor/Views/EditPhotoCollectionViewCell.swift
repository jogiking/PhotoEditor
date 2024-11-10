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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        emojiImageView.snp.makeConstraints {
            $0.edges.equalToSuperview() // 셀의 전체를 이미지로 채움
        }
        emojiImageView.contentMode = .scaleAspectFit // 이미지가 셀에 맞게 조정되도록 설정
    }
    
    func configure(with image: UIImage?) {
        emojiImageView.image = image
    }
}
