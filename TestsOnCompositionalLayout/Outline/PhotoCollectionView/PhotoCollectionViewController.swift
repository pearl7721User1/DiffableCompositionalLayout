//
//  PhotoCollectionViewController.swift
//  TestsOnCompositionalLayout
//
//  Created by Giwon Seo on 2023/01/19.
//

import UIKit

class PhotoCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos = [GiwonPhoto]()
    private var dataSource: UICollectionViewDiffableDataSource<Int, GiwonPhoto>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
    }
    

    private func createLayout() -> UICollectionViewLayout {
        
        // create an item
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0/3.0), heightDimension: .fractionalWidth(1.0/3.0))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets.init(top: 1.0, leading: 1.0, bottom: 1.0, trailing: 1.0)
        
        // create a group out of the items
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1.0/3.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout.init(section: section)
        return layout

    }
    
    private func configureDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Int, GiwonPhoto>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: GiwonPhoto) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.init(describing: "PhotoCell"), for: indexPath)
            
            // load image if it is needed
            self.photos[indexPath.item].loadResource(isReset: false)
            
            if let imageView = cell.viewWithTag(1) as? UIImageView {
                imageView.image = self.photos[indexPath.item].image
            }
            
            return cell
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, GiwonPhoto>()
        snapshot.appendSections([0])
        snapshot.appendItems(photos, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension PhotoCollectionViewController {
    static func newInstance() -> PhotoCollectionViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String.init(describing: PhotoCollectionViewController.self)) as! PhotoCollectionViewController
        return vc
    }
}
