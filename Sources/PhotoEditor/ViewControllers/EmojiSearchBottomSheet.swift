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
    EmojiSearchBottomSheet(emojiDataSource: MockEmojiDataSource())
})

protocol EmojiSearchBottomSheetDelegate: AnyObject {
    func didSelectEmojiItem(image: UIImage?)
    func didSelectBottomSheetEmojiCategory(indexPath: IndexPath)
}

final class EmojiSearchBottomSheet: UIViewController {
    
    // MARK: - UI Components
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
    
    private var items: [UIImage] = []
    
    weak var selectDelegate: EmojiSearchBottomSheetDelegate?
    
    private let viewModel: EditPhotoViewModel
    
    // MARK: - Life Cycle
    
    public init(emojiDataSource: EditPhotoEmojiDataSource) {
        self.viewModel = EditPhotoViewModel(emojiDataSource: emojiDataSource)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animateBottomContainer()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        bottomContainerView.backgroundColor = .black
        collectionView.backgroundColor = .clear
        
        setupSubviews()
        setupConstraints()
        setupCollectionView()
        
        emojiOptionView.closeButton.addTarget(self, action: #selector(closeEmojiTapped), for: .touchUpInside)
    }
    
    private func setupSubviews() {
        view.addSubview(collectionView)
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(emojiOptionView)
    }
    
    private func setupConstraints() {
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
    
    private func animateBottomContainer() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseInOut) {
                self.bottomContainerView.snp.updateConstraints {
                    $0.height.equalTo(80 + self.view.safeAreaInsets.bottom)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func configure(with items: [UIImage], options: [UIImage], selectedIndex: IndexPath) {
        self.items = items
        collectionView.reloadData()
        
        emojiOptionView.configure(with: options, selectedIndex: selectedIndex)
    }
    
    // MARK: - Collection View Setup
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
    }
    
    // MARK: - Actions
    @objc private func closeEmojiTapped() {
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
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
            self.selectDelegate?.didSelectEmojiItem(image: self.items[indexPath.item])
        }
    }
}

// MARK: - ImageCell

final class ImageCell: UICollectionViewCell {
    
    static let identifier = "ImageCell"
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}

// MARK: - EmojiOptionViewDelegate

extension EmojiSearchBottomSheet: @preconcurrency EmojiOptionViewDelegate {
    func didSelectEmojiCategory(indexPath: IndexPath) {
        self.selectDelegate?.didSelectBottomSheetEmojiCategory(indexPath: indexPath)
    }
}
