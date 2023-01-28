//
//  PhotoController.swift
//  TestsOnCompositionalLayout
//
//  Created by Giwon Seo on 2023/01/11.
//

import UIKit

class PhotoController {
    static var shared: PhotoController = {
        let photoController = PhotoController()
        return photoController
    }()
    
    private let photoResourceManager = PhotoResourceManager()
    private var photos = [GiwonPhoto]()
    
    // MARK: - AlbumViewController DataSources
    private (set) var allCategories = [AlbumCategoryListDataSource]()
    private (set) var allAlbums = [AlbumListDataSource]()
    
    init() {
        photos = photoResourceManager.loadPhotoResourceInfos()
        reCalculateDataSources()
    }
    
    // MARK: - Populating data for initial setup
    private func reCalculateDataSources() {
        // make it a set first to delete duplications
        let categorySet = Set<String>.init(photos.map({$0.category}))
        let categoryArray = Array(categorySet).sorted(by: {$0 < $1})
        
        // create data source
        var categoryDataSources = [AlbumCategoryListDataSource]()
        categoryArray.forEach { category in
            
            let data = AlbumCategoryListDataSource.init(category: GiwonPhoto.PhotoCategory(rawValue: category) ?? .cat, numberOfPhotos: photos.filter({$0.category == category}).count)
            categoryDataSources.append(data)
        }
        
        // set category list data source
        allCategories = categoryDataSources
        
        // make it a set first to delete duplications
        let albumNameSet = Set<String>.init(photos.map({$0.albumName}))
        let albumArray = Array(albumNameSet).sorted(by: {$0 < $1})

        // create data source
        var albumDataSources = [AlbumListDataSource]()
        albumArray.forEach { albumName in
            
            var photosThatFall = photos.filter({$0.albumName == albumName})
            
            // load first photo's resource to make thumbnail
            // since GiwonPhoto data type is struct, call out mutating function in-place of the array
            var image: UIImage?
            if photosThatFall.isEmpty == false {
                photosThatFall[0].loadResource(isReset: true)
                image = photosThatFall[0].image
            }
            
            let data = AlbumListDataSource.init(album: GiwonPhoto.Album.init(rawValue: albumName) ?? .Favorites, numberOfPhotos: photosThatFall.count, thumbnailImage: image)
            albumDataSources.append(data)
        }
        
        // set album list data source
        allAlbums = albumDataSources
    }
    
    
    
    func photos(from category:GiwonPhoto.PhotoCategory) -> [GiwonPhoto] {
        return photos.filter({$0.category == category.rawValue})
    }
    
    func photos(from album:GiwonPhoto.Album) -> [GiwonPhoto] {
        return photos.filter({$0.albumName == album.rawValue})
    }
    
    // MARK: - Data Changes
    /// Calling addSOlidImage() create changes in data. It appends a new element to photos and directly update the datasources
    func addSolidImage() {
        
        // create a solid image
        guard let randomColor = UIColor.bluishColors().randomElement(),
        let image = UIImage.solidColorImage(randomColor) else { return }
        
        // randomly distribute album and category to create a GiwonPhoto
        var newPhoto = GiwonPhoto.init(category: GiwonPhoto.PhotoCategory.allCases.randomElement()?.rawValue ?? "", albumName: GiwonPhoto.Album.allCases.randomElement()?.rawValue ?? "", fileName: "")
        newPhoto.feedImage(image: image)
        
        // update data
        // 1 photos
        // 2 allAlbums
        // 3 allCategories
        
        // add to photos property
        photos.append(newPhoto)
        
        // find the index among the allAlbums and mutate dataSources(allAlbums) directly
        for (i,album) in allAlbums.enumerated() {
            if album.albumName == newPhoto.albumName {
                allAlbums[i].recentChanges = Date()
                allAlbums[i].numberOfPhotos += 1
            }
        }

        // re-sorted in a way that album of the most recent changes come first
        // before sorting create a snapshot
        let beforeSnapshots = allAlbums.map({$0.hashValue})
        
        allAlbums.sort { lv, rv in
            
            if let lvChanges = lv.recentChanges {
                if let rvChanges = rv.recentChanges {
                    return lvChanges > rvChanges
                } else {
                    return true
                }
            } else {
                if rv.recentChanges != nil {
                    return false
                } else {
                    return lv.albumName < rv.albumName
                }
            }
        }
        
        // after sorting create a snapshot
        let afterSnapshots = allAlbums.map({$0.hashValue})
        
        // find the index among the allCategories and mutate dataSource(allCategories) directly
        for (i,category) in allCategories.enumerated() {
            if category.categoryName == newPhoto.category {
                allCategories[i].numberOfPhotos += 1
            }
        }
        
        //
        // ** here, manually figuring out changes is not needed when diffable datasource is used.
        // simply letting the viewcontroller knows the changes and updating the snapshot will do exactly the same
        // for typical datasource, create AlbumListDataSourceChange array so that view controller changes animatedly
        // compare beforeSnapshots and afterSnapshots
        var changes = [AlbumViewController.AlbumListDataSourceChange]()
        for (i,beforeSnapshot) in beforeSnapshots.enumerated() {
            
            let fromIndex = i
            var toIndex = i
            for (j, afterSnapshot) in afterSnapshots.enumerated() {
                
                if afterSnapshot == beforeSnapshot {
                    toIndex = j
                    break
                }
                
            }
            
            let change = AlbumViewController.AlbumListDataSourceChange.init(fromIndex: fromIndex, toIndex: toIndex)
            changes.append(change)
        }
        
        NotificationCenter.default.post(name: Notification.Name.PhotoControllerUpdated, object: nil, userInfo: ["IndexChanges":changes])
    }
}

extension Notification.Name {
    static var PhotoControllerUpdated = Notification.Name.init(rawValue: "PhotosUpdated")
}

extension UIImage {
    static func solidColorImage(_ color: UIColor, size: CGSize = CGSize(width: 32, height: 32)) -> UIImage? {
        var image: UIImage?
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.set()
        let path = UIBezierPath.init(rect: rect)
        path.fill()
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIColor {
    static func bluishColors() -> [UIColor] {
        let r = [36, 44, 46, 41, 45].map({$0/255.0})
        let g = [92, 188, 152, 120, 40].map({$0/255.0})
        let b = [245, 250, 245, 250, 245].map({$0/255.0})

        var colors = [UIColor]()
        for i in 0..<r.count {
            let color = UIColor.init(red: r[i], green: g[i], blue: b[i], alpha: 1.0)
            colors.append(color)
        }
        
        return colors
    }
}
