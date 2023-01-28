//
//  File.swift
//  TestsOnCompositionalLayout
//
//  Created by Giwon Seo on 2023/01/14.
//

import UIKit

struct AlbumListDataSource: Hashable {
    let album: GiwonPhoto.Album
    var albumName: String {
        return album.rawValue
    }
    var numberOfPhotos: Int
    let thumbnailImage: UIImage?
    
    // UI layer property
    var recentChanges: Date?
    
    private let id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

struct AlbumCategoryListDataSource: Hashable {
    let category: GiwonPhoto.PhotoCategory
    var categoryName: String {
        return category.rawValue
    }
    var numberOfPhotos: Int
    
    private let id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

enum CellSectionKind: Int, CaseIterable {
    case album, category
    
    var cellIdentifier: String {
        switch self {
        case .album:
            return "albumCell"
        case .category:
            return "categoryCell"
        }
    }
    
    var title: String {
        switch self {
        case .album:
            return "My Albums"
        case .category:
            return "Category"
        }
    }
    
}

enum SupplementaryCellKind: String {
    case commonHeader
}


struct AlbumViewLayoutCreator {
    
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let layoutKind = CellSectionKind(rawValue: sectionIndex) else { return nil }

            let standardSpacing: CGFloat = 7
            let fixedLeading: CGFloat = standardSpacing*2.0
            let fixedTrailing: CGFloat = standardSpacing*2.0
            let groupAbsoluteWidth = layoutEnvironment.container.effectiveContentSize.width - fixedLeading - fixedTrailing
            
            let cellLabelsHeight = 50.0
            let groupAbsoluteHeight = ((groupAbsoluteWidth - standardSpacing*2.0) / 2.0) * 2.0 + cellLabelsHeight * 2.0 + standardSpacing * 2.0
            
            // define section header for common
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .absolute(50))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: sectionHeaderSize,
                elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            
            if layoutKind == .album {
                let leadingItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(0.5)))
                leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: standardSpacing, bottom: standardSpacing, trailing: standardSpacing)
                let leadingGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                      heightDimension: .fractionalHeight(1.0)),
                    subitem: leadingItem, count: 2)
                
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(groupAbsoluteWidth),
                                                       heightDimension: .absolute(groupAbsoluteHeight))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [leadingGroup])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                
                // add header
                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                
                
                return section
            }
        
            if layoutKind == .category {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupHeight = NSCollectionLayoutDimension.absolute(50)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: groupHeight)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                
                // add header
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            }
            
            return nil
        }
        return layout
        
    }
}
