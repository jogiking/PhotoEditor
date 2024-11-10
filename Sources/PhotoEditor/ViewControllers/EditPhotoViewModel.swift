//
//  EditPhotoViewModel.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import Foundation

import UIKit

public protocol EditPhotoEmojiDataSource: Sendable {
    func loadEmojiSection() async -> [UIImage]
    func loadEmojiItems(for section: Int) async -> [UIImage]
}

@MainActor
final class EditPhotoViewModel {
    
    let emojiDataSource: EditPhotoEmojiDataSource
    
    init (emojiDataSource: EditPhotoEmojiDataSource) {
        self.emojiDataSource = emojiDataSource
    }
    
    // 이모지 섹션 로드
    nonisolated func fetchEmojiSection() async -> [UIImage] {
        return await emojiDataSource.loadEmojiSection()
    }
    
    // 특정 섹션의 이모지 아이템 로드
    nonisolated func fetchEmojiItems(for section: Int) async -> [UIImage] {
        return await emojiDataSource.loadEmojiItems(for: section)
    }
}
