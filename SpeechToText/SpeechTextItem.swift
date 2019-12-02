//
//  SpeechTextItem.swift
//  SpeechToText
//
//  Created by Ankita Ghosh on 27/11/19.
//  Copyright © 2019 mebonku. All rights reserved.
//

import RealmSwift

class SpeechTextItem: Object {
    @objc dynamic var text = ""
    
    convenience init(text: String) {
        self.init()
        self.text = text
    }
}
