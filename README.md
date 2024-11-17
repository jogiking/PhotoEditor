# PhotoEditor

A powerful photo editing tool designed for quick integration into your iOS projects.

## ✨ Features
- Image Attachment: Add images to the canvas.
- Scale & Rotate: Zoom, rotate, and adjust attached images.
- Drawing: Draw on Image using customizable colors.
- Undo/Redo: Reverse or reapply recent changes.
- Save Edited Image: Save final edits using the delegate method.


## 📦 Installation

### Using Swift Package Manager
Add the following line to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jogiking/PhotoEditor.git", from: "1.0.0")
]
```

## 🚀 Quick Start

Here's how to quickly set up and use the `PhotoEditor`:

### Import the Library
First, import `PhotoEditor` at the top of your Swift file:

```swift
import PhotoEditor

class MyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Button action to open the Photo Editor
    @IBAction func openPhotoEditorButtonTouched(_ sender: Any) {
        let vc = EditPhotoViewController(emojiDataSource: MyEmojiDataSource())
        present(vc, animated: true, completion: nil)
    }
}

// Custom Emoji Data Source Implementation
struct MyEmojiDataSource: EditPhotoEmojiDataSource {

    /// Loads sections of images (e.g., categories)
    func loadEmojiSection() async -> [UIImage] {
        let sectionImages = [
            "borabuki_on",
            "floki_on",
            "flosuni_on",
            "leechorok_on",
            "pengflo_on"
        ]
        return sectionImages.compactMap { UIImage(named: $0) }
    }

    /// Loads images for a specific section
    func loadEmojiItems(for section: Int) async -> [UIImage] {
        let itemImages = [
            "borabuki_on",
            "floki_on",
            "flosuni_on",
            "leechorok_on",
            "pengflo_on"
        ]
        return itemImages.compactMap { UIImage(named: $0) }
    }
}

extension MyViewController: EditPhotoViewControllerDelegate {

    /// Called when the user saves the edited image
    func saveEditedImage(_ image: UIImage) {
        // Handle the edited image
        print("Edited image has been saved successfully!")
    }
}

```
### Explanation
- **`EditPhotoViewController`**: This view controller provides the main interface for editing photos.
- **`emojiDataSource`**: An object that supplies images(e.g., emojis) for use in the editor. It conforms to the `EditPhotoEmojiDataSource` protocol.
- **`MyEmojiDataSource`**: A sample implementation of the `EditPhotoEmojiDataSource` protocol. It demonstrates how to load a set of images both for sections and specific items.
- **`EditPhotoViewControllerDelegate`** A protocol to handle the saving of edited images.

## 🛠️ Customization
You can create your own custom data source by conforming to the `EditPhotoEmojiDataSource` protocol. This allows you to dynamically load any set of emojis you wish to include.

## 📄 License
**PhotoEditor** is licensed under the MIT License.
