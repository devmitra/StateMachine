//: Playground - noun: a place where people can play

import UIKit
import StateMachine
//import XCPlayground
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


enum Events : String, EventDescriptor {
    case One,Two
}

enum States : String, StateIdentifier {
    case X,Y,Z
}

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

let stateMachine : StateMachine<States,[String : Any], Events> = StateMachine<States,[String : Any], Events>()

let x: StateX = StateX(state: .X)
let y: StateY = StateY(state: .Y)
stateMachine.addState(x)
stateMachine.addState(y)

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

try! stateMachine.start(state: .X)

stateMachine.handleEvent(.One, nil)
stateMachine.handleEvent(.Two, nil)

handle.remove()

stateMachine.handleEvent(.One, nil)
