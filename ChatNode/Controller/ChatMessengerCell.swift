//
//  ChatMessengerCell.swift
//  ChatNode
//
//  Created by Mr.Long on 11/9/18.
//  Copyright © 2018 LoNguyen. All rights reserved.
//

import UIKit

class ChatMessengerCell: UICollectionViewCell {
    
    var textView: UITextView = {
        let tv = UITextView()
        tv.text = "example"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        addSubview(textView)
        textView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
