//
//  GiwonPhotoView.swift
//  TestsOnCompositionalLayout
//
//  Created by Giwon Seo on 2023/01/15.
//

import UIKit

extension UIImageView {
    
    /// scale scale aspect fill
    func scaleDownToSet(image: UIImage?) {
        
        guard let image = image else { return }
        
        // ui element render size
        let minSize = CGSize.init(width: self.frame.size.width * UIScreen.main.nativeScale, height: self.frame.size.height * UIScreen.main.nativeScale)
        
        // if image doesn't have to be scaled down, do not proceed, otherwise cpu is wasted
        guard image.size.width > minSize.width,
              image.size.height > minSize.height else {
            self.image = image
            return
        }
        
        // scale down
        let aspectFillSize = aspectFill(aspectRatio: image.size, minimumSize: minSize)
        
        let renderer = UIGraphicsImageRenderer(size: aspectFillSize)
        let scaleDownImage = renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: aspectFillSize))
        }
        
        self.image = scaleDownImage
    }
    
    private func aspectFill(aspectRatio :CGSize, minimumSize: CGSize) -> CGSize {
        let mW = minimumSize.width / aspectRatio.width
        let mH = minimumSize.height / aspectRatio.height

        var newSize = minimumSize
        
        if( mH > mW ) {
            newSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width
        }
        else if( mW > mH ) {
            newSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height
        }
        
        return newSize
    }
}
