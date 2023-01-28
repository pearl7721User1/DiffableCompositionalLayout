//
//  File.swift
//  TestsOnCompositionalLayout
//
//  Created by Giwon Seo on 2023/01/11.
//

import UIKit

struct GiwonPhoto: Hashable {
    
    enum PhotoCategory: String, CaseIterable {
        case cat, dog, nature, drawing, food
    }
    
    enum Album: String, CaseIterable {
        case Recents, Illustrations, Note, Favorites, WhatsApp, Instagram
    }
    
    let category: String
    let albumName: String
    let fileName: String
    
    // resource
    private (set) var image: UIImage?
    
    mutating func loadResource(isReset: Bool) {
        
        if isReset == false, image != nil {
            return
        }
        
        // extension can be either JPG or PNG
        let fileName1 = fileName + ".JPG"
        let fileName2 = fileName + ".PNG"
        
        let jpgImage = UIImage.init(named: fileName1)
        let pngImage = UIImage.init(named: fileName2)
        
        if jpgImage != nil {
            image = jpgImage
        }
        if pngImage != nil {
            image = pngImage
        }
    }
    
    mutating func feedImage(image: UIImage) {
        self.image = image
    }
    
}

extension GiwonPhoto: Codable {
    // Codable
    enum CodingKeys: String, CodingKey {
        case category
        case albumName
        case fileName
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        category = try values.decode(String.self, forKey: .category)
        albumName = try values.decode(String.self, forKey: .albumName)
        fileName = try values.decode(String.self, forKey: .fileName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(category, forKey: .category)
        try container.encode(albumName, forKey: .albumName)
        try container.encode(fileName, forKey: .fileName)
    }
}
