//
//  ViewController.swift
//  ChatNode
//
//  Created by Mr.Long on 11/1/18.
//  Copyright © 2018 LoNguyen. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController {

    let manager = SocketManager(socketURL: URL(string: "http://localhost:2016")!, config: [.log(true), .compress])
    var socket: SocketIOClient? = nil
    
    let defaults = UserDefaults.standard
    var username: String = "null"
    
    var term = "null"
    
    var listUsers = [Users]()
    
    let selectFriendTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let friendPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        view.backgroundColor = UIColor.white

        //create socket.
        
        term = "seted"
        // MARK: -initview
        view.addSubview(selectFriendTextField)
        setupSelectUserTextField()
        setupToolbarOfSelectUser()
        
        // END MARK: -
        

        

        
    }//viewdidload

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let nameCookie = defaults.string(forKey: "userName"){
            username = nameCookie
            navigationController?.navigationBar.topItem?.title = username
            socket = manager.defaultSocket
            socket!.connect()
            socket!.on("connect") { _, _ in
                self.socket!.emit("client_send_name", [self.username])
                
            }
            
            
            socket?.on("server_send_listUser", callback: { (data, ack) in
                let dataDictionary = data as! [NSDictionary]
                self.giveListUserFromServer(dataDic: dataDictionary)
            })
        }else{
            handleLogout()
            
        }

        
    }// view did appear
    
    
    func sendNameToServer(name: String) {
        print("CallBack")
        socket = manager.defaultSocket
        socket!.connect()
        socket!.on("connect") { _, _ in
            self.socket!.emit("client_send_name", [name])
            print("nameis: \(name)")
        }

        
        
    }

    func giveListUserFromServer(dataDic: [NSDictionary]){
        

            listUsers.removeAll()
            let dataObject = dataDic[0].value(forKey: "userList") as! [NSObject]
            dataObject.forEach({ (user) in
                let u = Users(n: user.value(forKey: "name") as! String, i: user.value(forKey: "id") as! String)
                self.listUsers.append(u)
                self.friendPicker.reloadAllComponents()
                
            })
        
        
    }
    
    
    func setupSelectUserTextField(){
        selectFriendTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        selectFriendTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        selectFriendTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        selectFriendTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationController!.navigationBar.frame.height + 10).isActive = true
        
        
        friendPicker.delegate = self
        selectFriendTextField.inputView = friendPicker
        
        
        
    }
    func setupToolbarOfSelectUser() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = .black
        toolBar.tintColor = .white
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        selectFriendTextField.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    @objc func handleLogout(){
        defaults.removeObject(forKey: "userName")
        defaults.synchronize()
        
        socket?.disconnect()
        

        let loginController = LoginViewController()
        present(loginController, animated: true, completion: nil)
    }


}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listUsers.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(listUsers)[row].name 
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectFriendTextField.text = Array(listUsers)[row].name
    }
    
    
}
