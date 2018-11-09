//
//  LoginViewController.swift
//  ChatNode
//
//  Created by Mr.Long on 11/1/18.
//  Copyright © 2018 LoNguyen. All rights reserved.
//

import UIKit
import SocketIO

class LoginViewController: UIViewController {
    let defaults = UserDefaults.standard
    
    
    let inputContainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        
        view.addSubview(inputContainView)
        view.addSubview(loginButton)
        setupInputContainerView()
        setupLoginButton()
    }//viewDidLoad
    
    func setupInputContainerView(){
        inputContainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
        inputContainView.addSubview(nameTextField)
        
        nameTextField.leftAnchor.constraint(equalTo: inputContainView.leftAnchor, constant: 12).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: inputContainView.rightAnchor, constant: 12).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: inputContainView.heightAnchor).isActive = true
    }
    
    func setupLoginButton(){
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: inputContainView.bottomAnchor, constant: 12).isActive = true
        loginButton.widthAnchor.constraint(equalTo: inputContainView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func handleLogin() {
        if nameTextField.text != "" { 
            defaults.set(nameTextField.text, forKey: "userName")
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    

   

}



extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
