//
//  EmojiSearchBottomSheet.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

import SnapKit
import Then

@available(iOS 17.0, *)
#Preview(traits: .defaultLayout, body: {
    EmojiSearchBottomSheet()
})

protocol EmojiSearchBottomSheetDelegate: AnyObject {
    func didSelectEmojiItem(image: UIImage?)
}

final class EmojiSearchBottomSheet: UIViewController {
    private let bottomContainerView = UIView()
    private lazy var emojiOptionView = EmojiOptionView().then {
        $0.delegate = self
    }
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let items: [UIImage] = [
        "borabuki_on",
        "floki_on",
        "flosuni_on",
        "leechorok_on",
        "pengflo_on",
        "borabuki_on",
        "floki_on",
        "flosuni_on",
        "leechorok_on",
        "pengflo_on"
    ].map {
        UIImage.loadAsset(named: $0)
    }.compactMap(\.self)
    
    weak var selectDelegate: EmojiSearchBottomSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupLayouts()
        setupStyles()
        setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseInOut, animations: {
                self.bottomContainerView.snp.updateConstraints {
                    $0.height.equalTo(80 + self.view.safeAreaInsets.bottom)
                }
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func addSubviews() {
        view.addSubview(collectionView)
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(emojiOptionView)
    }
    
    private func setupLayouts() {
        bottomContainerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        emojiOptionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(15)
        }
    }
    
    private func setupStyles() {
        view.backgroundColor = .black
        bottomContainerView.backgroundColor = .black
        collectionView.backgroundColor = .clear
        
        emojiOptionView.closeButton.addTarget(self, action: #selector(closeEmojiTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
    }
    
    @objc func closeEmojiTapped() {
        print(#function)
        dismiss(animated: true) {
            self.selectDelegate?.didSelectEmojiItem(image: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension EmojiSearchBottomSheet: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.configure(with: items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let availableWidth = collectionView.frame.width - padding * 2
        let width = availableWidth / 3
        return CGSize(width: width, height: width) // Square cells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.selectDelegate?.didSelectEmojiItem(image: self.items[indexPath.row])
        }
    }
}

// MARK: - ImageCell

final class ImageCell: UICollectionViewCell {
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}

// MARK: - EmojiOptionViewDelegate

extension EmojiSearchBottomSheet: @preconcurrency EmojiOptionViewDelegate {
    func didSelectEmojiCategory(indexPath: IndexPath) {
        print(#function)
        // TODO: 다른 시트로 reload
    }
}
