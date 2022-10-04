//
//  BlockedViewController.swift
//  SecretGallery
//
//  Created by Антон Стафеев on 04.10.2022.
//

import LocalAuthentication
import ShimmerSwift
import UIKit
import SwiftKeychainWrapper

final class BlockedViewController: UIViewController {
    
    lazy var unblockButton: UIButton = {
        let button = GradientButton(colors: [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor, UIColor.systemBlue.cgColor] )
        button.frame = CGRect(x: 0, y: 0, width: 280, height: 50)
        button.setTitle("Разблокировать контент?", for: .normal)
        button.addTarget(self, action: #selector(unblockButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var password = MainViewController().myPassword
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        addSettingsForButton()
        
        password = KeychainWrapper.standard.string(forKey: "password") ?? "Не удалось загрузить пароль"
    }
    
    private func addSettingsForButton() {
        unblockButton.center = view.center
        view.addSubview(unblockButton)
        
        let shimmerView = ShimmeringView(frame: unblockButton.bounds)
        view.addSubview(shimmerView)
        shimmerView.center = view.center
        shimmerView.contentView = unblockButton
        shimmerView.isShimmering = true
        shimmerView.shimmerSpeed = 100
        shimmerView.shimmerAnimationOpacity = 0.8
    }
    
    @objc private func unblockButtonTapped() {
        let context = LAContext()
        var error: NSError? = nil
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Использовать Touch ID?"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {[weak self] succes, authError in
                DispatchQueue.main.async {
                    if succes {
                        self?.unlockVC()
                    } else {
                        self?.unlockWithPassword()
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Биометрия недоступна", message: "Войти с помощью пароля ?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.unlockWithPassword()
            })
            present(ac, animated: true)
        }
    }
    
    private func unlockWithPassword() {
        let ac = UIAlertController(title: "Введите пароль", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        ac.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
            textField.placeholder = "Пароль"
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let text = ac.textFields?[0].text else { return }
            
            if text == self?.password {
                self?.unlockVC()
            } else {
                let ac = UIAlertController(title: "Пароли не совпадают", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
            }
        })
        present(ac, animated: true)
    }
    
    private func unlockVC() {
        let navController = UINavigationController(rootViewController: MainViewController())
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true)
    }
}

