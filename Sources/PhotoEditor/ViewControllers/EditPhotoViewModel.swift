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

struct EditEvent {
    enum EventType {
        case addEmoji
        case addStroke
        case deleteEmoji
    }
    var targetView: UIView
    var eventType: EventType
}

@MainActor
final class EditPhotoViewModel {
    
    private(set) var undoEvent: [EditEvent] = []
    private(set) var redoEvent: [EditEvent] = []
    
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
    
    func addEditEvent(_ event: EditEvent) {
        undoEvent.append(event)
    }
    
    func popUndoEvent() -> EditEvent? {
        guard let lastEvent = undoEvent.popLast() else {
            return nil
        }
        redoEvent.append(lastEvent)
        return lastEvent
    }
    
    func popRedoEvent() -> EditEvent? {
        guard let lastEvent = redoEvent.popLast() else {
            return nil
        }
        undoEvent.append(lastEvent)
        return lastEvent
    }
}
