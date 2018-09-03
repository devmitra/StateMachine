//
//  TodoTableViewController.swift
//  StateMachine
//
//  Created by Pushan Mitra on 26/04/17.
//  Copyright © 2017 Pushan Mitra. All rights reserved.
//

import UIKit

class TodoTableViewController: UITableViewController {
    
    var handle : StateObservationHandle? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.applicationService.performOperation {
            self.handle = self.applicationService.stateMachine.addChangeObserver({ (event, current, next, store) in
                OperationQueue.main.addOperation({
                    switch next {
                    case .ViewTodo:
                        print("View Todo List")
                        if self.navigationController?.topViewController is TodoTableViewController {
                            self.performSegue(withIdentifier: "pushTodoView", sender: self)
                        }
                        else {
                            print("Item in display")
                        }
                    case .ViewTodoList:
                        
                        if self.navigationController?.topViewController is TodoViewController {
                           let _ = self.navigationController?.popToRootViewController(animated: true)
                        }
                        if event != TodoEvent.RemoveTodo {
                            self.tableView.reloadData()
                        }
                        
                    default:
                        print("No default action")
                        
                    }
                })
            })
        }
        
        if !self.applicationService.stateMachine.handleEvent(.Start, nil) {
            print("Not able to send Start event")
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.applicationService.todoStore.list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        cell.textLabel?.text = self.applicationService.todoStore.list[indexPath.row]

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _ = self.applicationService.stateMachine.handleEvent(.ViewTodo, indexPath.row)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            
            //tableView.deselectRow(at: indexPath, animated: true)
            
            if !self.applicationService.stateMachine.handleEvent(.RemoveTodo, indexPath.row) {
                print("Unable to handle event RemoveTodo")
            }
            
            self.applicationService.queue.addOperation {
                OperationQueue.main.addOperation {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func addTodo(_ sender: UIBarButtonItem) {
        
        if !self.applicationService.stateMachine.handleEvent(.AddTodo, nil) {
            print("State machine not able to handle AddTodo Event")
        }
    }
    
    
    @IBAction func removeTodo(_ sender: UIBarButtonItem) {
    }
    

}
