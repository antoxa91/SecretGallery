//
//  MainViewController.swift
//  SecretGallery
//
//  Created by Антон Стафеев on 04.10.2022.
//
import SwiftKeychainWrapper
import UIKit

final class MainViewController: UIViewController {
    
    private let picsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 4, right: 2)
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PicsCollectionViewCell.self,
                                forCellWithReuseIdentifier: PicsCollectionViewCell.identifier)
        collectionView.backgroundColor = .black
        collectionView.bounces = false
        return collectionView
    }()
    
    var myPics = [Images]()
    let defaults = UserDefaults.standard
    
    var lockButton: UIBarButtonItem!
    var setPasswordButton: UIBarButtonItem!
    
    var myPassword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        
        navigationController?.navigationBar.tintColor = .systemMint
        title = "Секретная галерея"
        
        setPasswordButton = UIBarButtonItem(image: UIImage(systemName: "key.viewfinder"), style: .plain, target: self, action: #selector(setPasswordTapped))
        lockButton = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(lockButtonTapped))
        lockButton.tintColor = .red
        navigationItem.leftBarButtonItems = [setPasswordButton, lockButton]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPicTapped))
        
        view.addSubview(picsCollectionView)
        setDelegates()
        loadSavedImages()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(lockButtonTapped), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc private func setPasswordTapped() {
        let ac = UIAlertController(title: "Создайте пароль", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        ac.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
            textField.placeholder = "Придумайте пароль"
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) {[weak self] _ in
            if let text = ac.textFields?[0].text {
                self?.myPassword = text
                KeychainWrapper.standard.set(self?.myPassword ?? "Не удалось сохранить", forKey: "password")
            }
        })
        present(ac, animated: true)
    }
    
    @objc func lockButtonTapped() {
        let vc = BlockedViewController()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        picsCollectionView.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    
    private func setDelegates() {
        picsCollectionView.delegate = self
        picsCollectionView.dataSource = self
    }
    
    
    // MARK: - ContextMenu
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let imageForDelete = myPics[indexPath.item]
        let config = UIContextMenuConfiguration(actionProvider:
                                                    {[weak self] _ in
            let deleteItem = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.deletePic(index: indexPath, image: imageForDelete)
                self?.saveArrayOfMyPics()
            }
            
            return UIMenu(
                title: "Действия",
                options: UIMenu.Options.displayInline,
                children: [deleteItem]
            )
        })
        return config
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.detailImage.image = getMyPic(by: indexPath)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        myPics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PicsCollectionViewCell.identifier, for: indexPath) as? PicsCollectionViewCell else { return UICollectionViewCell() }
        cell.myImageView.image = getMyPic(by: indexPath)
        return cell
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func addPicTapped() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {return}
        
        let imageName = UUID().uuidString
        let imagePath = Images.getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.5) {
            try? jpegData.write(to: imagePath)
        }
        let newPic = Images(image: imageName)
        myPics.append(newPic)
        
        DispatchQueue.main.async {
            self.picsCollectionView.reloadData()
        }
        saveArrayOfMyPics()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Save, delete & load images
extension MainViewController {
    private func loadSavedImages() {
        if let savedImages = defaults.object(forKey: Images.key) as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                myPics = try jsonDecoder.decode([Images].self, from: savedImages)
            } catch {
                print("Failed to load myPics")
            }
        }
    }
    
    private func saveArrayOfMyPics() {
        let jsonEncoder = JSONEncoder()
        guard let savedData = try? jsonEncoder.encode(myPics) else { return }
        defaults.set(savedData, forKey: Images.key)
    }
    
    private func deletePic(index: IndexPath, image: Images) {
        myPics.remove(at: index.item)
        picsCollectionView.reloadData()
    }
    
    private func getMyPic(by indexPath: IndexPath) -> UIImage {
        let image = myPics[indexPath.item]
        let path = Images.getDocumentsDirectory().appendingPathComponent(image.image)
        guard let myPic = UIImage(contentsOfFile: path.path) else { return UIImage() }
        return myPic
    }
}


// MARK: - Size for item
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/3.08,
                      height: view.frame.size.width/3.08)
    }
}

