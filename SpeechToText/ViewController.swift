//
//  ViewController.swift
//  SpeechToText
//
//  Created by Ankita Ghosh on 27/11/19.
//  Copyright © 2019 mebonku. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var sentenceListTable: UITableView!
    @IBOutlet weak var microphoneButton: UIButton!
    
    private lazy var speechController: SpeechController = {
        let speechController = SpeechController()
        speechController.delegate = self
        return speechController
    }()
    var textList: Results<SpeechTextItem> {
        get {
            let realm = try! Realm()
            return realm.objects(SpeechTextItem.self)
        }
    }
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.microphoneButton.backgroundColor = UIColor(red: 208/255, green: 81/255, blue: 37/255, alpha: 0.4)
        // Do any additional setup after loading the view.
    }
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(textList.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "TEXT")
        
        let textItem = textList[indexPath.row]
        cell.textLabel?.text = textItem.text
        
        return cell
    }
    
    //MARK: - IBActions
    @IBAction private func recordingAction(_ sender: Any) {
        self.startOrStopRecording()
    }
    
    func startOrStopRecording() {
        isRecording = !isRecording
        if isRecording {
            self.microphoneButton.backgroundColor = UIColor(red: 110/255, green: 195/255, blue: 102/255, alpha: 0.4)
            do {
                try speechController.startRecording()
            } catch {
                print("Could not record")
            }
        } else {
            self.microphoneButton.backgroundColor = UIColor(red: 208/255, green: 81/255, blue: 37/255, alpha: 0.4)
            speechController.stopRecording()
            self.saveTheText(textInput.text)
        }
    }
    
    //MARK: DB Actions
    func saveTheText(_ text: String?) {
        guard let text = text else {
            return
        }
        
        let newTextItem = SpeechTextItem()
        newTextItem.text = text
        let realm = try! Realm()
        try! realm.write {
            realm.add(newTextItem)
        }
        sentenceListTable.reloadData()
    }
}

extension ViewController: SpeechControllerDelegate {
    //MARK: - Speech controller delegate
    func speechController(_ speechController: SpeechController, didRecogniseText text: String) {
        textInput.text = text
    }
    
    func speechControllerdidEndTalking() {
        self.startOrStopRecording()
    }
    
}

