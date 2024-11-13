//
//  EditPhotoViewControllerDelegate.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit
import PencilKit
import AVFoundation

import SnapKit
import Then

@available(iOS 17.0, *)
#Preview(traits: .defaultLayout, body: {
    EditPhotoViewController(emojiDataSource: MockEmojiDataSource())
})

@objc public protocol EditPhotoViewControllerDelegate: class {
    func saveEditedImage(_ image: UIImage)
}

@objcMembers public class EditPhotoViewController: UIViewController {
    // gesture state
    private var initialBounds = CGRect.zero
    private var initialTouchPoint = CGPoint.zero
    private var initialCenter = CGPoint.zero
    private var initialRotationAngle: CGFloat = 0
    
    // 삽입 이미지 영역
    private var insertedImages: [StickerImageView] = []
    private var selectedImageView: StickerImageView?
    
    // 삭제한 뷰 임시저장
    private var removedViews: [UIView] = []
    
    var originImage: UIImage? {
        didSet {
            mainImageView.image = originImage
        }
    }
    
    weak var delegate: EditPhotoViewControllerDelegate?
    
    private let viewModel: EditPhotoViewModel

    // 드로잉 영역
    private lazy var canvasView = PKCanvasView().then {
        if #available(iOS 17.0, *) {
            $0.tool = PKInkingTool(.crayon, color: .red, width: 10)
        } else {
            $0.tool = PKInkingTool(.marker, color: .red, width: 10)
        }
        $0.drawingPolicy = .anyInput
        $0.backgroundColor = .clear
        $0.delegate = self
    }
    private let mainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private lazy var dismissButton = UIButton(type: .custom).then {
        $0.setImage(UIImage.loadAsset(named: "icon_close24"), for: .normal)
        $0.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
    }
    private lazy var saveButton = UIButton(type: .custom).then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    private lazy var undoButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(systemName: "arrow.uturn.backward.circle"), for: .normal)
        $0.tintColor = .white
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
    }
    private lazy var redoButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(systemName: "arrow.uturn.forward.circle"), for: .normal)
        $0.tintColor = .white
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.addTarget(self, action: #selector(redoTapped), for: .touchUpInside)
    }
    private lazy var mainImageContainerView = UIView().then {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedImageBackground))
        $0.addGestureRecognizer(tapGesture)
    }
    private let bottomContainerView = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let allOptionView = SelectAllOptionView()
    private lazy var emojiOptionView = EmojiOptionView().then {
        $0.isHidden = true
        $0.delegate = self
    }
    private lazy var canvasOptionView = CanvasOptionView().then {
        $0.isHidden = true
        $0.delegate = self
    }
    
    private var currentOptionMode: OptionMode = .default
    
    public init(emojiDataSource: EditPhotoEmojiDataSource) {
        self.viewModel = EditPhotoViewModel(emojiDataSource: emojiDataSource)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupLayouts()
        setupStyles()
        
        loadAssets()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#function, #file)
    }
    
    private func addSubviews() {
        view.addSubview(dismissButton)
        view.addSubview(saveButton)
        view.addSubview(undoButton)
        view.addSubview(redoButton)
        view.addSubview(mainImageContainerView)
        view.addSubview(bottomContainerView)
        mainImageContainerView.addSubview(mainImageView)
        mainImageContainerView.addSubview(canvasView)
        [allOptionView, emojiOptionView, canvasOptionView].forEach { subview in
            bottomContainerView.addSubview(subview)
        }
    }
    
    private func setupLayouts() {
        dismissButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.size.equalTo(24)
        }
        saveButton.snp.makeConstraints {
            $0.centerY.equalTo(dismissButton)
            $0.trailing.equalToSuperview().inset(12)
        }
        undoButton.snp.makeConstraints {
            $0.centerY.equalTo(dismissButton)
            $0.leading.equalTo(dismissButton.snp.trailing).offset(24)
            $0.size.equalTo(24)
        }
        redoButton.snp.makeConstraints {
            $0.top.equalTo(undoButton)
            $0.leading.equalTo(undoButton.snp.trailing).offset(10)
            $0.size.equalTo(24)
        }
        mainImageContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(dismissButton.snp.bottom).offset(8)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(80)
        }
        canvasView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mainImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.lessThanOrEqualToSuperview()
            $0.height.lessThanOrEqualToSuperview()
        }
        bottomContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 34
            $0.height.equalTo(80 + bottomInset)
        }
        allOptionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        emojiOptionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        canvasOptionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
    }

    private func updateRedoUndoAppearance() {
        undoButton.isEnabled = mainImageContainerView.subviews.count > 2
        redoButton.isEnabled = removedViews.count > 0
    }
    
    private func loadAssets() {
        Task {
            // 이모지 섹션
            emojiOptionView.configure(with: await viewModel.fetchEmojiSection(), selectedIndex: nil)
        }
    }
    
    private func addStroke(image: UIImage, bounds: CGRect) {
        let newImageView = UIImageView(image: image)
        newImageView.frame = bounds
        newImageView.isUserInteractionEnabled = false
        
        self.selectedImageView?.isSelected = false // 기존 이미지가 있다면 선택해제
        self.canvasView.isUserInteractionEnabled = true // 캔버스 Drawing 활성화
        
        mainImageContainerView.addSubview(newImageView)
        updateRedoUndoAppearance()
    }
    
    private func addImage(image: UIImage? = nil) {
        let newImageView = StickerImageView()
        if let image = image {
            newImageView.imageView.image = image
        }
        newImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        newImageView.center = canvasView.center
        newImageView.isUserInteractionEnabled = true
        newImageView.isSelected = true
        
        // 이미지 중앙 드래그 이동
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        newImageView.addGestureRecognizer(panGesture)
        
        // 이미지 탭 선택
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage(_:)))
        newImageView.addGestureRecognizer(tapGesture)
        
        // 삭제 탭 선택
        let tapDeleteGesture = UITapGestureRecognizer(target: self, action: #selector(deleteImage(_:)))
        newImageView.deleteView.addGestureRecognizer(tapDeleteGesture)
        
        // 핸들 드래그 크기 조절 및 회전
        let handlePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleHandlePan(_:)))
        newImageView.handleView.addGestureRecognizer(handlePanGesture)
        
        self.insertedImages.append(newImageView)

        self.selectedImageView?.isSelected = false // 기존 이미지가 있다면 선택해제
        self.canvasView.isUserInteractionEnabled = false // 캔버스 Drawing 비활성화
        self.selectedImageView = newImageView
        
        mainImageContainerView.addSubview(newImageView)
        
        // 이미지가 추가된 후 애니메이션 효과 적용
        newImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut]) {
            newImageView.transform = .identity
        }
    }
    
    private func setupStyles() {
        view.backgroundColor = .black
        bottomContainerView.backgroundColor = .black
        mainImageView.image = originImage
        
        // 바닥 전체옵션뷰 설정
        allOptionView.openEmojiButton.addTarget(self, action: #selector(openEmojiTapped), for: .touchUpInside)
        allOptionView.openCanvasButton.addTarget(self, action: #selector(openCanvasTapped), for: .touchUpInside)
        // 이모지 옵션뷰 설정
        emojiOptionView.closeButton.addTarget(self, action: #selector(closeEmojiTapped), for: .touchUpInside)
        // canvas 옵션뷰 설정
        canvasOptionView.closeButton.addTarget(self, action: #selector(closeEmojiTapped), for: .touchUpInside)
        
        transition(mode: currentOptionMode)
        updateRedoUndoAppearance()
    }
    
    @objc func dismissTapped() {
        print(#function)
        dismiss(animated: true)
    }
    
    @objc func saveTapped() {
        print(#function)
        let imageFrame = AVMakeRect(aspectRatio: mainImageView.image?.size ?? .zero, insideRect: mainImageView.frame)
        let targetFrame = mainImageContainerView.convert(imageFrame, to: mainImageContainerView)
        let renderer = UIGraphicsImageRenderer(bounds: targetFrame)
        let convertedImage = renderer.image { rendererContext in
            self.mainImageContainerView.layer.render(in: rendererContext.cgContext)
        }
        delegate?.saveEditedImage(convertedImage)
        dismiss(animated: true)
    }
    
    // 바닥 옵션 전환
    private func transition(mode: OptionMode) {
        switch mode {
        case .default:
            allOptionView.isHidden = false
            emojiOptionView.isHidden = true
            canvasOptionView.isHidden = true
            selectedImageView?.isSelected = false
            canvasView.isUserInteractionEnabled = false
        case .emoji:
            allOptionView.isHidden = true
            emojiOptionView.isHidden = false
            canvasOptionView.isHidden = true
        case .canvas:
            allOptionView.isHidden = true
            emojiOptionView.isHidden = true
            canvasOptionView.isHidden = false
            selectedImageView?.isSelected = false
            mainImageContainerView.bringSubviewToFront(canvasView)
            canvasView.isUserInteractionEnabled = true
        }
    }
    
    @objc func openEmojiTapped() {
        print(#function)
        currentOptionMode = .emoji
        transition(mode: currentOptionMode)
    }
    
    @objc func openCanvasTapped() {
        print(#function)
        currentOptionMode = .canvas
        transition(mode: currentOptionMode)
    }
    
    @objc func closeEmojiTapped() {
        print(#function)
        currentOptionMode = .default
        transition(mode: currentOptionMode)
    }
    
    @objc func closeCanvasTapped() {
        print(#function)
        currentOptionMode = .default
        transition(mode: currentOptionMode)
    }
    
    @objc func undoTapped() {
        if let lastModifiedView = mainImageContainerView.subviews.reversed().first(where: {
            $0 != mainImageView && $0 != canvasView
        }) {
            if let stickerImageView = lastModifiedView as? StickerImageView {
                stickerImageView.isSelected = false
                if let indexOfSelectedImage = insertedImages.firstIndex(of: stickerImageView) {
                    insertedImages.remove(at: indexOfSelectedImage)
                }
            }
            
            lastModifiedView.removeFromSuperview()
            
            removedViews.append(lastModifiedView)
        }
        
        updateRedoUndoAppearance()
        transition(mode: currentOptionMode)
    }
    
    @objc func redoTapped() {
        if let recentlyRemovedView = removedViews.popLast() {
            if let stickerIamgeView = recentlyRemovedView as? StickerImageView {
                insertedImages.append(stickerIamgeView)
            }
            
            mainImageContainerView.addSubview(recentlyRemovedView)
        }
        
        updateRedoUndoAppearance()
        transition(mode: currentOptionMode)
    }

    @objc private func selectImage(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? StickerImageView else { return }
        
        let isPreviousSelected = selectedImageView?.isSelected ?? false
        selectedImageView?.isSelected = false // 기존선택된건 무조건 비활성화
        if imageView == selectedImageView {
            imageView.isSelected = !isPreviousSelected
        } else {
            imageView.isSelected = true
        }
        selectedImageView = imageView
        
        // 방금 선택한걸 가장 최상단으로 올린다
        if let indexOfSelectedImage = insertedImages.firstIndex(of: imageView) {
            insertedImages.remove(at: indexOfSelectedImage)
            insertedImages.append(imageView)
        }
        mainImageContainerView.bringSubviewToFront(imageView)
        
        // 선택 상태에 따라 PencilKit 입력 활성화/비활성화
        canvasView.isUserInteractionEnabled = !imageView.isSelected
    }
    
    // 선택중인 이미지 삭제
    @objc private func deleteImage(_ gesture: UITapGestureRecognizer) {
        guard let imageView = selectedImageView, imageView.isSelected else { return }
        if let indexOfSelectedImage = insertedImages.firstIndex(of: imageView) {
            insertedImages.remove(at: indexOfSelectedImage)
        }
        imageView.removeFromSuperview()
        canvasView.isUserInteractionEnabled = true
        
        updateRedoUndoAppearance()
    }
    
    // 스티커 이미지 외부 터치시 모든 선택 이미지 비활성화 처리
    @objc private func didTappedImageBackground() {
        selectedImageView?.isSelected = false
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        print(#function)
        guard let imageView = selectedImageView, imageView.isSelected else { return }
        
        let touchPoint = gesture.location(in: view)
        switch gesture.state {
        case .began:
            initialCenter = imageView.center
            initialTouchPoint = touchPoint
        case .changed:
            let offsetX = touchPoint.x - initialTouchPoint.x
            let offsetY = touchPoint.y - initialTouchPoint.y
            imageView.center = CGPoint(x: initialCenter.x + offsetX, y: initialCenter.y + offsetY)
        default:
            break
        }
    }

    @objc private func handleHandlePan(_ gesture: UIPanGestureRecognizer) {
        print(#function)
        guard let imageView = selectedImageView, imageView.isSelected else { return }
        
        let touchPoint = gesture.location(in: view)
        switch gesture.state {
        case .began:
            initialBounds = imageView.bounds
            initialTouchPoint = touchPoint
            // 현재 회전 각도 저장
            initialRotationAngle = atan2(imageView.transform.b, imageView.transform.a)
        case .changed:
            // 크기 조절
            let deltaWidth = touchPoint.x - initialTouchPoint.x
            let deltaHeight = touchPoint.y - initialTouchPoint.y
            let newWidth = initialBounds.width + deltaWidth
            let newHeight = initialBounds.height + deltaHeight
            
            // 최소 및 최대 크기 제한 설정
            let minSize: CGFloat = 50
            let maxSize: CGFloat = 300
            if newWidth > minSize && newWidth < maxSize && newHeight > minSize && newHeight < maxSize {
                imageView.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
            }
            
            // 회전 각도 계산
            let angleOffset = atan2(touchPoint.y - imageView.center.y, touchPoint.x - imageView.center.x) - atan2(initialTouchPoint.y - imageView.center.y, initialTouchPoint.x - imageView.center.x)
            imageView.transform = CGAffineTransform(rotationAngle: initialRotationAngle + angleOffset)
        default:
            break
        }
    }
}

extension EditPhotoViewController: EmojiOptionViewDelegate {
    func didSelectEmojiCategory(indexPath: IndexPath) {
        print(#function, indexPath)
        let vc = EmojiSearchBottomSheet(emojiDataSource: viewModel.emojiDataSource)
        vc.selectDelegate = self
        vc.configure(selectedIndex: indexPath)
        
        if let sheet = vc.sheetPresentationController {
            sheet.delegate = self
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            self.bottomContainerView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            self.view.layoutIfNeeded()
        }) { _ in
            self.present(vc, animated: true)
        }
    }
}

extension EditPhotoViewController: UISheetPresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.bottomContainerView.snp.updateConstraints {
                    $0.height.equalTo(80 + self.view.safeAreaInsets.bottom)
                }
                self.view.layoutIfNeeded()
            })
        }
    }
}

extension EditPhotoViewController: EmojiSearchBottomSheetDelegate {
    // 이모지 최종 선택 이벤트
    func didSelectEmojiItem(image: UIImage?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.bottomContainerView.snp.updateConstraints {
                    $0.height.equalTo(80 + self.view.safeAreaInsets.bottom)
                }
                self.view.layoutIfNeeded()
            })
            
            if let image = image {
                self.addImage(image: image)
                self.updateRedoUndoAppearance()
            }
        }
    }
    
    // 이모지 카테고리 선택
    func didSelectBottomSheetEmojiCategory(indexPath: IndexPath) {
        self.emojiOptionView.updateSelection(selectedIndex: indexPath)
    }
}

extension EditPhotoViewController: CanvasOptionViewDelegate {
    // 컬러칩 최종 선택 이벤트
    func didSelectDrawingColor(hex: String) {
        print(#function)
        if #available(iOS 17.0, *) {
            canvasView.tool = PKInkingTool(.crayon, color: hex.stringToColor, width: 10)
        } else {
            canvasView.tool = PKInkingTool(.marker, color: hex.stringToColor, width: 10)
        }
    }
}

extension EditPhotoViewController: PKCanvasViewDelegate {
    public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if let lastStroke = canvasView.drawing.strokes.last {
            let image = canvasView.drawing.image(from: lastStroke.renderBounds, scale: UIScreen.main.scale)
            self.addStroke(image: image, bounds: lastStroke.renderBounds)
            canvasView.drawing = PKDrawing()
        }
    }
}

enum OptionMode {
    case `default`
    case emoji
    case canvas
}
