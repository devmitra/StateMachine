//: Playground - noun: a place where people can play
//  Created by Pushan Mitra on 12/07/16.
//  Copyright © 2016 IBM INDIA PVT LTD And Pushan Mitra. All rights reserved.

import UIKit
import StateMachine
//import XCPlayground
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

/*:
 # State Machine: Tutorial
 State machine is excelent concept of application development. Here whole application is composed into
 serveral unique states which is represented by state variable,(i.e. Store). Events triggered state transition. StateMachine framework provides excelent development tool to develop application based on state machine. This Swift (3.0) framework is a generic reusable code component. Generic represenattion of Event, StateIdentifier or StateName and State behavior can be achived through this frame work.
 
 #### Please build StateMachine project to run this tutorial
 */


//: Events : Must confrom to EventDescriptor
enum Events : String, EventDescriptor {
    case One,Two,Three
}

// States : State identifier or state name
enum States : String, StateNames {
    case X,Y,Z
}

// State : State behavior controller composed with type Events and States and it is applicable to same kind of state machine.
class StateX : State<States,[String: Any],Events> {
    override func operation(_ event: Events, _ store: [String : Any]?, _ completion: Completion) {
        print("State X ----- Processing Event : \(event)")
        completion(next: States.Y, store: nil)
    }
}

class StateY : State<States,[String: Any],Events> {
    override func operation(_ event: Events, _ store: [String : Any]?, _ completion: Completion) {
        print("State Y ----- Processing Event : \(event)")
        completion(next: States.X, store: nil)
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

//:  Adding handle
let handleSyncStateMachine: StateObservationHandle = stateMachineSync.addChangeObserver { (e,p,n,_) in
    print("Get observation sync \(e) --- \(p) --- \(n)")
}

//:  Starting machine with state X
try! stateMachineSync.start(state: .Y)

//:  Events
stateMachineSync.handleEvent(.Two, nil)
stateMachineSync.handleEvent(.One, nil)

//: Removing handle
handleSyncStateMachine.remove()

//: No observation call after removal
stateMachineSync.handleEvent(.Three, nil)

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
    print("Get observation \(e) --- \(p) --- \(n)")
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
try! stateMachine.start(state: .X)


//:  Handling events
stateMachine.handleEvent(.One, nil)

/*:!
 ### Asynchronous behavior 
 *   Not accepting synchronous event call
 */
stateMachine.handleEvent(.One, nil)

//: #### Checking async behavior
let timeInSec = 1.0
DispatchQueue.main.after(when: .now() + timeInSec) {
    // your function here
    let _ = stateMachine.handleEvent(.Two, nil)
    
    handle.remove()
    let timeInSec = 1.0
    DispatchQueue.main.after(when: .now() + timeInSec) {
        // your function here
        let _ = stateMachine.handleEvent(.Three, nil)
    }
}

