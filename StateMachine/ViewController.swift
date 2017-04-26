//
//  ViewController.swift
//  StateMachine
//
//  Created by Pushan Mitra on 12/07/16.
//  Copyright © 2016 Pushan Mitra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    func testStateMachine()  {
        /*enum Events : String, EventDescriptor {
            case One,Two,Three
        }
        
        // States : State identifier or state name
        enum States : String, StateNames {
            case X,Y,Z
        }
        
        // State : State behavior controller composed with type Events and States and it is applicable to same kind of state machine.
        class StateX : State<States,[String: Any],Events> {
            override func operation(_ event: Events, _ store: [String : Any]?,_ data: Any?, _ completion: Completion) {
                print("State X ----- Processing Event : \(event)")
                completion(States.Y, nil)
            }
            
            override func possibleNextStates() -> [States]? {
                return [States.Y]
            }
        }
        
        class StateY : State<States,[String: Any],Events> {
            override func operation(_ event: Events, _ store: [String : Any]?,_ data: Any?, _ completion: Completion) {
                print("State Y ----- Processing Event : \(event)")
                completion(States.X, nil)
            }
            
            override func possibleNextStates() -> [States]? {
                return [States.X]
            }
        }
        
        let x: StateX = StateX(state: .X)
        let y: StateY = StateY(state: .Y)
        
        /*:
         ## State Machine
         A generic state machine which accepts Events as Events for state machine and States as States as StateIdentifier or state name.
         This machine accepts only similer state with same types.
         */
        
        /*:
         ## Synchronous State Machine
         State machine without operation queue
         */
        let stateMachineSync : StateMachine<States,[String : Any], Events> = StateMachine<States,[String : Any], Events>()
        
        //:  Adding states
        stateMachineSync.addState(x)
        stateMachineSync.addState(y)
        
        print("\(stateMachineSync.stateDiagram)")
        
        //:  Adding handle
        let handleSyncStateMachine: StateObservationHandle = stateMachineSync.addChangeObserver { (e,p,n,_) in
            print("Get observation sync \(e) --- \(String(describing: p)) --- \(n)")
        }
        
        //:  Starting machine with state X
        let _ = try! stateMachineSync.start(state: .Y)
        
        //:  Events
        let _ = stateMachineSync.handleEvent(.Two, nil)
        let _ = stateMachineSync.handleEvent(.One, nil)
        
        //: Removing handle
        let _ = handleSyncStateMachine.remove()
        
        //: No observation call after removal
        let _ = stateMachineSync.handleEvent(.Three, nil)
        
        /*:
         ## Async State Machine
         State machine with own operation queue
         */
        let stateMachine : StateMachine<States,[String : Any], Events> = StateMachine<States,[String : Any], Events>(queue: OperationQueue.main)
        
        //: Adding states
        stateMachine.addState(x)
        stateMachine.addState(y)
        
        
        //: Create Observation and notification
        let handle: StateObservationHandle = stateMachine.addChangeObserver { (e,p,n,_) in
            print("Get observation \(e) --- \(String(describing: p)) --- \(n)")
        }
        
        class Observer {
            @objc func notificationHandle(notification: Notification) {
                print("Get notification")
                if let stmac: StateMachine<States,[String : Any], Events> = notification.userInfo?[StateMachineKey] as? StateMachine<States,[String : Any], Events> {
                    
                    print("\(stmac)")
                }
                
            }
        }
        
        let observer: Observer = Observer()
        
        NotificationCenter.default.addObserver(observer, selector: #selector(Observer.notificationHandle), name:Notification.Name(StateMachineChangeNotification), object: nil)
        
        
        
        //: Starting machine with state X
        let _ = try! stateMachine.start(state: .X)
        
        
        //:  Handling events
        let _ = stateMachine.handleEvent(.One, nil)
        
        /*:!
         ### Asynchronous behavior
         *   Not accepting synchronous event call
         */
        let _ = stateMachine.handleEvent(.One, nil)
        
        //: #### Checking async behavior
        let timeInSec = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInSec) {
            // your function here
            let _ = stateMachine.handleEvent(.Two, nil)
            
            handle.remove()
            let timeInSec = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInSec) {
                // your function here
                let _ = stateMachine.handleEvent(.Three, nil)
            }
        }*/
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

