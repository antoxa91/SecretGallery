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
        
        Images.shared.loadSavedPics()
        
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
        let config = UIContextMenuConfiguration(actionProvider: {[weak self] _ in
            let deleteItem = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                let imageForDelete = Images.shared.myPics[indexPath.item]
                guard let picsCollectionView = self?.picsCollectionView else { return }
                Images.shared.deletePic(
                    index: indexPath,
                    image: imageForDelete,
                    picsCollectionView: picsCollectionView)
                Images.shared.saveArrayOfMyPics()
            }
            
            return UIMenu(title: "Действия", options: .displayInline, children: [deleteItem])
        })
        return config
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.detailImage.image = Images.shared.getMyPic(by: indexPath)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Images.shared.myPics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PicsCollectionViewCell.identifier, for: indexPath) as? PicsCollectionViewCell else { return UICollectionViewCell() }
        cell.myImageView.image = Images.shared.getMyPic(by: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/3.08,
                      height: view.frame.size.width/3.08)
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
        let imagePath = Images.shared.getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.5) {
            try? jpegData.write(to: imagePath)
        }
        let newPic = Images(image: imageName)
        
        Images.shared.myPics.append(newPic)
        
        DispatchQueue.main.async {
            self.picsCollectionView.reloadData()
        }
        Images.shared.saveArrayOfMyPics()
        dismiss(animated: true, completion: nil)
    }
}


