//
//  GifCollectionViewCell.swift
//  GifSearch
//
//  Created by Pauls Slankis on 25/12/2022.
//

import UIKit
import FLAnimatedImage

class GifCollectionViewCell: UICollectionViewCell {
    static let identifier = "GifCollectionViewCell"
    
    private let imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with urlString: String){
        
        guard let url = URL(string: urlString) else {
            return
        }
        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request){
            // The GIF's data is in the cache
            let gifData = cachedResponse.data
            let gif = FLAnimatedImage(animatedGIFData: gifData)
            DispatchQueue.main.async {
                self.imageView.animatedImage = gif
            }
        } else {
            // The GIF's data is not in the cache
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    let gif = FLAnimatedImage(animatedGIFData: data)
                    self?.imageView.animatedImage = gif
                }
            }.resume()
        }
    }
}
