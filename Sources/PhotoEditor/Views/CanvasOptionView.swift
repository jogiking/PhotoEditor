//
//  CanvasOptionView.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

import SnapKit
import Then

protocol CanvasOptionViewDelegate: AnyObject {
    func didSelectDrawingColor(hex: String)
}

final class CanvasOptionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var delegate: CanvasOptionViewDelegate? = nil
    
    private let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 14
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.delegate = self
        $0.dataSource = self
    }
    let closeButton = UIButton(type: .custom).then {
        $0.setImage(UIImage.loadAsset(named: "icon_close16"), for: .normal)
        $0.tintColor = .white
    }
    let closeBackgroundView = UIView().then {
        $0.backgroundColor = "333333".stringToColor
        $0.layer.cornerRadius = 16
    }
    private let colors = [
        "6449FC",
        "FF3434",
        "FF5CAA",
        "FFB800",
        "00B01C",
        "000000",
        "FFFFFF"
    ]

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
        addSubview(collectionView)
        addSubview(closeBackgroundView)
        closeBackgroundView.addSubview(closeButton)
    }

    private func setupLayouts() {
        closeBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.center.equalToSuperview()
        }

        collectionView.snp.makeConstraints {
            $0.leading.equalTo(closeBackgroundView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.bottom.equalToSuperview()
        }
    }

    private func setupStyles() {
        backgroundColor = .black
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(EditPhotoColorChipCollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        
        DispatchQueue.main.async {
            let initialIndexPath = IndexPath(item: 0, section: 0)
            self.collectionView.selectItem(at: initialIndexPath, animated: false, scrollPosition: [])
            self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: initialIndexPath)
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! EditPhotoColorChipCollectionViewCell
        cell.configure(with: colors[indexPath.row])
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected color: \(colors[indexPath.item])")
        
        delegate?.didSelectDrawingColor(hex: colors[indexPath.item])
    }
}

final class EditPhotoColorChipCollectionViewCell: UICollectionViewCell {
    private let colorView = UIView()
    private var colorHex: String = ""
    
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
        contentView.addSubview(colorView)
    }
    
    private func setupLayouts() {
        colorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupStyles() {
        colorView.layer.cornerRadius = 4
        colorView.layer.masksToBounds = true
    }
    
    func configure(with color: String) {
        colorHex = color  // 선택된 색상 저장
        colorView.backgroundColor = color.stringToColor
        updateBorder()  // 초기 상태에 따라 테두리 적용
    }
    
    override var isSelected: Bool {
        didSet {
            updateBorder()
        }
    }
    
    private func updateBorder() {
        if isSelected {
            // 흰색 컬러칩일 경우 회색 테두리 적용
            if colorHex == "FFFFFF" {
                colorView.layer.borderWidth = 2
                colorView.layer.borderColor = UIColor.gray.cgColor
            } else {
                colorView.layer.borderWidth = 2
                colorView.layer.borderColor = UIColor.white.cgColor
            }
        } else {
            colorView.layer.borderWidth = 0
            colorView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
