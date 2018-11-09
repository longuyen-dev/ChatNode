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
    var listMessage = [Messenger]()
    var myCollectionView: UICollectionView?

    let messageInput = UITextField()
    let selectFriendTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    
    let friendPicker = UIPickerView()
    var containerBottomConstants: NSLayoutConstraint?
    

    
    func setupInputComponents(){
        let containerView = UIView()
        containerView.backgroundColor = .red
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerBottomConstants = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        containerBottomConstants!.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        messageInput.placeholder = "Aa"
        messageInput.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(messageInput)
        
        messageInput.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        messageInput.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        messageInput.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 3/4).isActive = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        let sendBtn = UIButton(type: .system)
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.setTitleColor(UIColor.white, for: .normal)
        sendBtn.addTarget(self, action: #selector(handleSendMessenger), for: .touchUpInside)
        containerView.addSubview(sendBtn)
        
        sendBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendBtn.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendBtn.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1/4).isActive = true
        
    }
    
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
        
        setupInputComponents()
        
        setupMessageCollectionView()
        
        
        
        

        
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
            socket?.on("server_send_messenger", callback: { (data, ack) in
                let dataDictionary = data as! [NSDictionary]
                let text = dataDictionary[0].value(forKey: "text") as! String
                let name = dataDictionary[0].value(forKey: "user") as! String
                let newMess = Messenger(n: name, t: text)
                self.listMessage.append(newMess)
                self.myCollectionView?.reloadData()
                print()
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
    
    func setupMessageCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: view.frame.width, height: 60)
        
        let myFrame = CGRect(x: 0, y: 100, width: view.frame.width, height: (view.frame.height) - 200)
        myCollectionView = UICollectionView(frame: myFrame, collectionViewLayout: layout)
        myCollectionView!.dataSource = self
        myCollectionView!.delegate = self
        myCollectionView!.register(ChatMessengerCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView!.backgroundColor = UIColor.clear
        view.addSubview(myCollectionView!)
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
    
    @objc func handleSendMessenger(){
        let newMessenger = ["text": messageInput.text!, "user": username]
        socket?.emit("client_send_messenget", with: [newMessenger])
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
    @objc func handleKeyboardWillChange(notice: Notification) {
        let keyboardFrame = notice.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardDuration = notice.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        
        containerBottomConstants?.constant = -(keyboardFrame.height)
        UIView.animate(withDuration: keyboardDuration as! TimeInterval) {
            self.view.layoutIfNeeded()
        }
        
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
extension ViewController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listMessage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! ChatMessengerCell
        myCell.textView.text = Array(listMessage)[indexPath.item].text
        return myCell
    }
    
    
}
