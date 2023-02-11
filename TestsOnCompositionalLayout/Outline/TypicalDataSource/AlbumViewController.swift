//
//  AlbumViewController.swift
//  TestsOnCompositionalLayout
//
//  Created by Giwon Seo on 2023/01/10.
//

import UIKit

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    struct AlbumListDataSourceChange {
        let fromIndex: Int
        let toIndex: Int
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Do any additional setup after loading the view.
        collectionView.collectionViewLayout = AlbumViewLayoutCreator().createLayout()
        
        // register supplementary views
        collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SupplementaryCellKind.commonHeader.rawValue)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(photosUpdatedCallback), name: Notification.Name.PhotoControllerUpdated, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
        //
        // to remove spacing caused by groupPagingCentered behavior
        // need to call out first time only
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func photosUpdatedCallback(_ notification: Notification) {
        if let indexChanges = notification.userInfo?["IndexChanges"] as? [AlbumListDataSourceChange] {
            
            collectionView.performBatchUpdates {
                for indexChange in indexChanges {
                    let from = IndexPath.init(item: indexChange.fromIndex, section: CellSectionKind.album.rawValue)
                    let to = IndexPath.init(item: indexChange.toIndex, section: CellSectionKind.album.rawValue)
                    collectionView.moveItem(at: from, to: to)
                }
            } completion: { finished in
                self.collectionView.reloadData()
            }

        }

    }
    
    @IBAction func plusButtonTapped(_ button: UIButton) {
        PhotoController.shared.addSolidImage()
    }
    
}

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return CellSectionKind.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == CellSectionKind.album.rawValue {
            return PhotoController.shared.allAlbums.count
        }
        if section == CellSectionKind.category.rawValue {
            return PhotoController.shared.allCategories.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == CellSectionKind.album.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellSectionKind.album.cellIdentifier, for: indexPath)
            
            let album = PhotoController.shared.allAlbums[indexPath.item]
            
            if let thumbnailImageView = cell.viewWithTag(1) as? UIImageView {
                thumbnailImageView.image = album.thumbnailImage
                
                // rounding
                thumbnailImageView.layer.cornerRadius = 8.0
            }
            
            if let albumNameLabel = cell.viewWithTag(2) as? UILabel {
                albumNameLabel.text = album.albumName
            }
            
            if let numberOfPhotosLabel = cell.viewWithTag(3) as? UILabel {
                numberOfPhotosLabel.text = "\(album.numberOfPhotos)"
            }
            
            return cell
        }
        
        if indexPath.section == CellSectionKind.category.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellSectionKind.category.cellIdentifier, for: indexPath)
            
            let category = PhotoController.shared.allCategories[indexPath.item]
            
            if let categoryLabel = cell.viewWithTag(1) as? UILabel {
                categoryLabel.text = category.categoryName
            }
            
            if let numberOfPhotosLabel = cell.viewWithTag(2) as? UILabel {
                numberOfPhotosLabel.text = "\(category.numberOfPhotos)"
            }
            
            // if first cell, hide separator
            if let separator = cell.viewWithTag(3) {
                
                if indexPath.item == 0 {
                    separator.isHidden = true
                } else {
                    separator.isHidden = false
                }
                
            }
            
            
            
            return cell
        }

        // no cells defined
        fatalError("no any cells defined")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplementaryCellKind.commonHeader.rawValue, for: indexPath) as? TitleSupplementaryView else {
                
                fatalError("Unexpected elementKindSectionHeader")
            }
            
            let sectionKind = CellSectionKind.init(rawValue: indexPath.section)
            headerView.label.text = sectionKind?.title

            return headerView
        default:
            
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let newScene = PhotoCollectionViewController.newInstance()
        
        guard let kind = CellSectionKind.init(rawValue: indexPath.section) else { return }
        
        switch kind {
        case .album:
            let album = PhotoController.shared.allAlbums[indexPath.item].album
            newScene.photos = PhotoController.shared.photos(from: album)
        case .category:
            let category = PhotoController.shared.allCategories[indexPath.item].category
            newScene.photos = PhotoController.shared.photos(from: category)
        }
        
        self.navigationController?.pushViewController(newScene, animated: true)
    }
    
}

