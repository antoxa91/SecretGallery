//
//  Images.swift
//  SecretGallery
//
//  Created by Антон Стафеев on 04.10.2022.
//

import UIKit

final class Images: NSObject, Codable {
    
    var image: String
    private var key = "myPics"
    var myPics = [Images]()
    
    init(image: String) {
        self.image = image
    }
    
    static let defaults = UserDefaults.standard
    static let shared = Images(image: UUID().uuidString)
    
    // MARK: - Save, delete & load images
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadSavedPics() {
        if let savedImages = Images.defaults.object(forKey: Images.shared.key) as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                Images.shared.myPics = try jsonDecoder.decode([Images].self, from: savedImages)
            } catch {
                print("Failed to load myPics")
            }
        }
    }
    
    func saveArrayOfMyPics() {
        let jsonEncoder = JSONEncoder()
        guard let savedData = try? jsonEncoder.encode(Images.shared.myPics) else { return }
        Images.defaults.set(savedData, forKey: Images.shared.key)
    }
    
    func deletePic(index: IndexPath, image: Images, picsCollectionView: UICollectionView) {
        Images.shared.myPics.remove(at: index.item)
        picsCollectionView.reloadData()
    }
    
    func getMyPic(by indexPath: IndexPath) -> UIImage {
        let myPicsIndex = Images.shared.myPics[indexPath.item]
        let path = Images.shared.getDocumentsDirectory().appendingPathComponent(myPicsIndex.image)
        guard let myPic = UIImage(contentsOfFile: path.path) else { return UIImage() }
        return myPic
    }
}
