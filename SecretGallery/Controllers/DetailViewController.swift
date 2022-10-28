//
//  DetailViewController.swift
//  SecretGallery
//
//  Created by Антон Стафеев on 04.10.2022.
//

import UIKit

final class DetailViewController: UIViewController {
    
    let detailImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var scrollView: ImageScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradietColor(
            colorOne: .init(red: 2/255, green: 4/255, blue: 20/255, alpha: 1),
            colorTwo: .init(red: 66/255, green: 2/255, blue: 10/255, alpha: 1),
            colorThree: .init(red: 2/255, green: 4/255, blue: 20/255, alpha: 1)
        )
        scrollView = ImageScrollView(frame: view.bounds)
        view.addSubview(scrollView)
        setConstraints()
        scrollView.set(image: detailImage.image ?? UIImage(systemName: "photo")!)
        scrollView.hideScreenshotContent()
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
