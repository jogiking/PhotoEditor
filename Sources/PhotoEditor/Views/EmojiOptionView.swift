//
//  EmojiOptionView.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

import SnapKit
import Then

protocol EmojiOptionViewDelegate: AnyObject {
    func didSelectEmojiCategory(indexPath: IndexPath)
}

final class EmojiOptionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var delegate: EmojiOptionViewDelegate? = nil
    
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
    
    private var emojis: [UIImage] = []
    
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
        collectionView.register(EditPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
    }
    
    func configure(with emojis: [UIImage], selectedIndex: IndexPath?) {
        self.emojis = emojis
        collectionView.reloadData()        
        updateSelection(selectedIndex: selectedIndex)
    }
    
    func updateSelection(selectedIndex: IndexPath?) {
        if let selectedIndex = selectedIndex {
            collectionView.selectItem(at: selectedIndex, animated: false, scrollPosition: .centeredHorizontally)
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! EditPhotoCollectionViewCell
        cell.configure(with: emojis[indexPath.row])
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected emoji: \(emojis[indexPath.item])")
        delegate?.didSelectEmojiCategory(indexPath: indexPath)
    }
}
