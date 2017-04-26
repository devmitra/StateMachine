//
//  TodoViewController.swift
//  StateMachine
//
//  Created by Pushan Mitra on 26/04/17.
//  Copyright © 2017 Pushan Mitra. All rights reserved.
//

import UIKit

class TodoViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.textView.text = self.applicationService.store.list[self.applicationService.store.seletedTodoItem]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editDone(_ sender: Any) {
        self.textView?.resignFirstResponder()
    }
    @IBAction func returnToList(_ sender: Any) {
        
       let _ = self.applicationService.stateMachine.handleEvent(.BackToList, nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TodoViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.textView?.resignFirstResponder()
        if !self.applicationService.stateMachine.handleEvent(.EditTodo, self.textView.text) {
            print("Unable to handle Edit todo event")
        }
        return true
    }
}
