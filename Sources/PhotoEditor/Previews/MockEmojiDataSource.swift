//
//  MockEmojiDataSource.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

import Kingfisher

struct MockEmojiDataSource: EditPhotoEmojiDataSource {
    
    public func loadEmojiSection() async -> [UIImage] {
        let images = [
            "borabuki_on",
            "floki_on",
            "flosuni_on",
            "leechorok_on",
            "pengflo_on"
        ].compactMap { UIImage.loadAsset(named: $0)! }
        
        return images
    }
    
    public func loadEmojiItems(for section: Int) async -> [UIImage] {
        let urls = [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Cat_poster_1.jpg/1280px-Cat_poster_1.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/1/13/Cat-ears.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/1/1d/Cat_paw_%28cloudzilla%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Cat_nose.jpg/800px-Cat_nose.jpg",
            "https://upload.wikimedia.org/wikipedia/ko/8/83/Cat_nap.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/8/83/Charline_the_cat_and_her_kittens.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Moxy_the_infant_kitten_being_bottle-fed.jpg/1280px-Moxy_the_infant_kitten_being_bottle-fed.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Cat_and_mouse.jpg/800px-Cat_and_mouse.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/6/6d/Listen%2C_do_you_want_to_know_a_secret.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/3/3b/Gato_enervado_pola_presencia_dun_can.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Large_Ragdoll_cat_tosses_a_mouse.jpg/1280px-Large_Ragdoll_cat_tosses_a_mouse.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/d/da/Cat_tongue_macro.jpg"
        ]
        
        return await withTaskGroup(of: (Int, UIImage?).self) { group in
            var images = Array<UIImage?>(repeating: nil, count: urls.count)
            
            for (index, url) in urls.enumerated() {
                group.addTask {
                    let image = await self.downloadImage(urlString: url)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image = image {
                    images[index] = image
                }
            }
            
            return images.compactMap { $0 }
        }
    }

    func downloadImage(urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        return await withCheckedContinuation { continuation in
            KingfisherManager.shared.retrieveImage(
                with: url,
                options: [
                    .memoryCacheExpiration(.expired),
                    .diskCacheExpiration(.expired)
                ]
            ) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value.image)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
