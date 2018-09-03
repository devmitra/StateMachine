//
//  AddViewController.swift
//  StateMachine
//
//  Created by Pushan Mitra on 28/04/17.
//  Copyright © 2017 Pushan Mitra. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, StateMachineObserver {
    public typealias AppStore = NumberAddStore
    public typealias AppState = NumberAddStates
    public typealias AppEvent = NumberAddEvents
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var expressionValLable: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var addUpdateButton: UIButton!
    
    var listenHandl: EventListener<StateMachine<AppState, NumberAddStore, AppEvent>.EventTuple>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = ""
        self.textView.delegate = self
        self.numberAddApp.performOperation {
            /*let _ = self.numberAddApp.stateMachine.addChangeObserver({ (event, current, next, store) in
                self.observeChange(event: event, current: current, next: next, store: store)
            })*/
            
            self.listenHandl = self.numberAddApp.stateMachine.on(handler: self.observeChange)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func observeChange(event: NumberAddEvents, current: NumberAddStates?, next: NumberAddStates, store: NumberAddStore?) {
        
        print("Event : \(event) | Previous : \(String(describing: current)) | next : \(next)")
        
        self.updateLabel()
        self.totalValueLabel.text = self.numberAddApp.store?.total.description
        
        if event == .EditExpression {
            self.textView.text = self.numberAddApp.stateMachine.store?.currentExpression
        }
        
        if self.numberAddApp.isEditMode {
            self.addUpdateButton.setTitle("Clear", for: .normal)
            
        } else {
            self.addUpdateButton.setTitle("Add", for: .normal)
        }
        
    }
    
    func updateLabel()  {
        if let str: String = self.numberAddApp.store?.currentExpression {
            self.expressionValLable.text = self.numberAddApp.store?.expressionToInt(exp: str).description
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func addExpression(_ sender: Any) {
        if self.numberAddApp.isEditMode {
            self.textView.text = ""
            let _ = self.numberAddApp.stateMachine.handleEvent(.Clear, nil)
        }
        else {
            let _ = self.numberAddApp.stateMachine.handleEvent(.AddExpression, self.textView.text)
        }
    }
}

extension AddViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text == "" {
            let _ = self.numberAddApp.stateMachine.handleEvent(.Clear, nil)
        }
        else {
            let text: NSString = textView.text as NSString
            let newText: String = text.replacingOccurrences(of: " ", with: "+")
            self.textView.text = newText
            
            if self.numberAddApp.isEditMode {
                let _ = self.numberAddApp.stateMachine.handleEvent(.UpdateExpression, textView.text)
            }
            else {
                let _ = self.numberAddApp.stateMachine.handleEvent(.CurrentExpression, textView.text)
            }
        }
        
        
        //self.updateLabel()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.textView?.resignFirstResponder()
        if self.numberAddApp.isEditMode {
            let _ = self.numberAddApp.stateMachine.handleEvent(.UpdateExpression, textView.text)
        }
        return true
    }
}
