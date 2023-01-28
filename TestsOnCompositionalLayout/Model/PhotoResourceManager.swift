//
//  File.swift
//  TestsOnCompositionalLayout
//
//  Created by Giwon Seo on 2023/01/13.
//

import Foundation

class PhotoResourceManager {
        
    fileprivate static let key = "PhotoResourceMetaData"
    
    func loadPhotoResourceInfos() -> [GiwonPhoto] {
        if let data = UserDefaults.standard.object(forKey: PhotoResourceManager.key) as? Data,
           let objects = try? JSONDecoder().decode([GiwonPhoto].self, from: data) {
            
            return objects
        }
        
        return [GiwonPhoto]()
    }
    
}

extension PhotoResourceManager {
    static func createAndSavePhotoResourceInfos() {
        var giwonPhotos = [GiwonPhoto]()
        
        var iteration = 1
        for category in GiwonPhoto.PhotoCategory.allCases {
            
            for album in GiwonPhoto.Album.allCases {
                
                let giwonPhoto = GiwonPhoto.init(category: category.rawValue, albumName: album.rawValue, fileName: "image\(iteration)")
                giwonPhotos.append(giwonPhoto)
                iteration += 1
            }
        }
        
        // To store in UserDefaults
        if let encoded = try? JSONEncoder().encode(giwonPhotos) {
            UserDefaults.standard.set(encoded, forKey: PhotoResourceManager.key)
        }

    }
}
