//
//  Images.swift
//  SecretGallery
//
//  Created by Антон Стафеев on 04.10.2022.
//

import UIKit

final class Images: NSObject, Codable {
    var image: String
    
    init(image: String) {
        self.image = image
    }
    
    static let key = "myPics"
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
