//: Playground - noun: a place where people can play

import UIKit
import StateMachine

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

try! stateMachine.start(state: .X)

stateMachine.handleEvent(.One, nil)
print("gap")
stateMachine.handleEvent(.Two, nil)
