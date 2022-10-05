//
//  ImageScrollView.swift
//  SecretGallery
//
//  Created by Антон Стафеев on 04.10.2022.
//

import UIKit

final class ImageScrollView: UIScrollView {
    
    var imageView: UIImageView!
    
    lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleZoomingTap))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.bounces = false
        self.decelerationRate = .fast
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(image: UIImage) {
        imageView?.removeFromSuperview()
        imageView = nil
        imageView = UIImageView(image: image)
        self.addSubview(imageView)
        configureFor(imageSize: image.size)
    }
    
    private func configureFor(imageSize: CGSize) {
        self.contentSize = imageSize
        setCurrentMaxAndMinZoomScale()
        self.zoomScale = self.minimumZoomScale
        self.imageView.addGestureRecognizer(self.zoomingTap)
        self.imageView.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.centerImage()
    }
    
    private func setCurrentMaxAndMinZoomScale() {
        let boundsSize = self.bounds.size
        let imageSize = imageView.bounds.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        self.minimumZoomScale = minScale
        
        var maxScale: CGFloat = 1.0
        
        if minScale < 0.1 {
            maxScale = 0.3
        }
        
        if minScale >= 0.1 && minScale < 0.5 {
            maxScale = 0.7
        }
        
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }
        self.maximumZoomScale = maxScale
    }
    
    private func centerImage() {
        let boundSize = self.bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundSize.width {
            frameToCenter.origin.x = (boundSize.width - frameToCenter.size.width) / 3
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundSize.height {
            frameToCenter.origin.y = (boundSize.height - frameToCenter.size.height) / 3
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
    
    // MARK: - Gesture
    @objc private func handleZoomingTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        self.zoom(point: location, animated: true)
    }
    
    private func zoom(point: CGPoint, animated: Bool) {
        let currentScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale
        
        if minScale == maxScale && minScale > 1 {
            return
        }
        
        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        let zoomRect = self.zoomRect(scale: finalScale, center: point)
        self.zoom(to: zoomRect, animated: animated)
    }
    
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        
        return zoomRect
    }
}

// MARK: - UIScrollViewDelegate
extension ImageScrollView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
}
