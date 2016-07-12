//
//  StateMachine.swift
//  StateMachine
//
//  Created by Pushan Mitra on 12/07/16.
//  Copyright © 2016 Pushan Mitra. All rights reserved.
//

import Foundation
public typealias EventCompletion = (nextState: String, store: Any?) -> Void
/**
 EventDescriptor
 Structural And Behavioral constrient of any event
 */
public protocol EventDescriptor: RawRepresentable  {
    var identifier:String {get}
}

public extension EventDescriptor {
    var identifier:String {
        if let s: String = self.rawValue as? String {
            return s
        }
        else {
            return ""
        }
    }
}

public protocol StateIdentifier: RawRepresentable, Hashable {
    init?(rawValue: String)
}


/**
 # StateDescriptor
 Structural And Behavioral constrient of any state
 */
//public protocol StateStructure {
//    associatedtype Store
//    associatedtype Event = EventDescriptor
//    var identifier: String {get}
//    func operation(_ event: Event,_ store: Store?, _ completion: EventCompletion) -> Void
//}
public class State<S: StateIdentifier,St, E: EventDescriptor>  {
    public typealias StateId = S
    public typealias Store = St
    public typealias Event  = E
    
    internal var state: StateId?
    
    public typealias Completion = (next : StateId, store: Store?) -> Void
    
    public var identifier: String {
        if let s: String = self.state?.rawValue as? String {
            return s
        }
        else {
            return ""
        }
    }
    
    public init(state: StateId) {
        self.state = state
    }
    
    public func operation(_ event: State.Event, _ store: State.Store?, _ completion: Completion) {
        
    }
    
    
}


public enum StateMachineError: ErrorProtocol {
    case StartError, MachineError
}


/*:
 # State Machine
 A state machine is collection of states of application and a store which is container of state variables. State machine handle a event and moves to next state.
 1. Container of states
 2. Handle Events
 3. Store state variables
 4. Store Event History
 5. Store State Transition
 */
public class StateMachine <StateId: StateIdentifier,Store, Event: EventDescriptor> {
    
    
    public typealias StateObj = State<StateId,Store,Event>
    public typealias StateAction = (Event,Store?,State<StateId,Store,Event>.Completion) -> Void
    
    /*:
     ### Store
     Stored property to hold state variables
     */
    public var store: Store?
    
    // Variables
    internal var currentState: StateId?
    internal var historyState: [StateId] = [StateId]()
    internal var historyEvent: [Event] = [Event]()
    internal var processing: Bool = false
    
    // Storing current State to history
    internal func storeCurrentStateToHistory() {
        if let c = self.currentState {
            historyState.append(c)
        }
    }
    // Event completion function
    internal func completion(next: StateId, store: Any?) {
        //print("Complete ---- next \(next)")
        processing = false
        
    }
    
    internal var states: [StateId : Any] = [StateId : Any]()
    
    public init() {
        
    }
    
    /*!
     ### addState (Action)
     Adding a new state Closure based action to StateMachine
     */
    public func addState (_ state: StateId, _ item : Any) {
        if  item is StateAction {
            states[state] = item
        }
    }
    
    /*!
     ### addState (State)
     Adding a new state State object based operation to StateMachine
     */
    public func addState(_ configuration: State<StateId,Store,Event>) {
        if let stid : StateId = configuration.state {
            states[stid] = configuration
        }
    }
    
    /*!
     ### handleEvent
     Handling event associated with application.
     */
    public func handleEvent(_ event: Event,_ data: Any?) -> Bool {
        if processing {
            //print("processing")
            return !processing
        }
        if let current: StateId = self.currentState, handle = states[current] {
            //print("get handel for \(currentState)")
            if let state: StateObj = handle as? StateObj {
                processing =  true
                state.operation(event, self.store, { [weak self](next, store) in
                    self?.completion(next: next, store: store)
                    })
            }
            else if let action: StateAction = handle as? StateAction {
                processing = true
                action(event, self.store, { (next, store) in
                    self.completion(next: next, store: store)
                })
            }
            else {
                processing = false
            }
        }
        else {
            processing = false
        }
        return processing
    }
    
    public func start(state : StateId) throws -> Bool  {
        if let _ = currentState {
            return false
        }
        currentState = state
        return true
    }
}
