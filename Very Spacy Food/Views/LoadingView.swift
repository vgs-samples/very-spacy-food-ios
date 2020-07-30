//
//  LoadingView.swift
//  Spacy Food
//
//  Created by Dima on 24.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

class LoadingView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var animationImages: [UIImage] = {
        getAnimationImage()
    }()
    
    class func fromNib() -> LoadingView? {
           return Bundle.main.loadNibNamed(String(describing: "LoadingView"), owner: nil, options: nil)?.first as? LoadingView
       }
    
    func startAnimation() {
        self.imageView.animationImages = animationImages
        self.imageView.animationDuration = 0.8
        self.imageView.startAnimating()
    }
    
    func stopAnimation() {
        self.imageView.stopAnimating()
    }
    
    private func getAnimationImage() -> [UIImage] {
        var images = [UIImage]()
        for i in 0..<4 {
            if let img = UIImage(named: "saturn_\(i)") {
                images.append(img)
            }
        }
        return images
    }
}
