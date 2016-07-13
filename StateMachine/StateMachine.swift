//
//  StateMachine.swift
//  StateMachine
//
//  Created by Pushan Mitra on 12/07/16.
//  Copyright © 2016 IBM INDIA PVT LTD And Pushan Mitra. All rights reserved.
//

import Foundation

/**
 # State Machine Notification
 */
public let StateMachineChangeNotification: String = "StateMachine.StateMachineChangeNotification"
public let StateMachineKey: String = "StateMachine.StateMachineKey"


public protocol StateObservationHandle {
    func remove()
}

/**
 # EventDescriptor
 Structural And Behavioral constrient of any event
 */
public protocol EventDescriptor: RawRepresentable  {
    var identifier:String {get}
}
// Defining defalut behaviour of event identification
public extension EventDescriptor {
    var identifier:String {
        if let s: String = self.rawValue as? String {
            return s
        }
        else {
            return "\(self.dynamicType)"
        }
    }
}

/**
 # StateIdentifier
 Programmatic representation of Identifier of state.
 */
public protocol StateIdentifier: RawRepresentable, Hashable {
    init?(rawValue: String)
}


/**
 # State
 Structural And Behavioral Structure of States in State Machine. Basically states is behavioral represenation of state.
 1. Handle state operation As per events
 2. Update state variable or store
 */
public class State<S: StateIdentifier,St, E: EventDescriptor>  {
    public typealias StateId = S
    public typealias Store = St
    public typealias Event  = E
    
    internal var state: StateId
    
    public typealias Completion = (next : StateId, store: Store?) -> Void
    
    public var identifier: String {
        if let s: String = self.state.rawValue as? String {
            return s
        }
        else {
            return "\(self.dynamicType)"
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

// Observation handler for state machine observation
struct StateMachineObservationHandle<T> : StateObservationHandle {
    var key: T?
    var removeClosure: ((T?) -> Void)?
    func remove()  {
        removeClosure?(key)
    }
    
    init(key: T) {
        self.key = key
    }
    
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
public class StateMachine <StateId: StateIdentifier,Store, Event: EventDescriptor>: CustomStringConvertible {
    
    
    public typealias StateObj = State<StateId,Store,Event>
    public typealias StateAction = (Event,Store?,State<StateId,Store,Event>.Completion) -> Void
    public typealias ChangeObserver = (Event,StateId?,StateId,Store?) -> Void
    
    
    
    /*:
     ### Store
     Stored property to hold state variables
     */
    public var store: Store?
    
    // Variables
    // Internal setter, public getter
    internal(set) public var currentState: StateId?
    
    internal var historyStates: [StateId] = [StateId]()
    internal var historyEvents: [Event] = [Event]()
    internal var observers: [Int : ChangeObserver] = [Int : ChangeObserver]()
    internal var observerCount: Int = 0
    internal var processing: Bool = false
    
    // Storing current State to history
    internal func storeCurrentStateToHistory() {
        if let c = self.currentState {
            historyStates.append(c)
        }
    }
    // Event completion function
    internal func completion(next: StateId, store: Any?) {
        //print("Complete ---- next \(next)")
        processing = false
        if self.currentState != next {
            self.storeCurrentStateToHistory()
            currentState = next
            if let  s: Store = store as? Store {
                self.store = s
            }
            
            sendChangeNotification(self.previuosState, next)
        }
    }
    
    // State configuration array
    internal var states: [StateId : Any] = [StateId : Any]()
    
    internal func sendChangeNotification(_ previous: StateId?,_ next: StateId) {
        let uinfo:[NSObject : AnyObject] = [StateMachineKey: self]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: StateMachineChangeNotification), object: nil, userInfo: uinfo)
        
        for (_,obsv) in observers {
            if let e: Event = self.lastEvent {
                obsv(e,previous,next,self.store)
            }
        }
    }
    
    public init() {}
    
    /**
     ### previousState
     */
    public var previuosState : StateId? {
        if historyStates.count > 0 {
            return historyStates.last
        }
        else {
            return nil
        }
    }
    
    public var lastEvent: Event? {
        if historyEvents.count > 0 {
            return historyEvents.last
        }
        else {
            return nil
        }
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
            let count1 = historyEvents.count
            if let state: StateObj = handle as? StateObj {
                processing =  true
                historyEvents.append(event)
                state.operation(event, self.store, { [weak self](next, store) in
                    self?.completion(next: next, store: store)
                    })
            }
            else if let action: StateAction = handle as? StateAction {
                processing = true
                historyEvents.append(event)
                action(event, self.store, {[weak self] (next, store) in
                    self?.completion(next: next, store: store)
                })
            }
            else {
                processing = false
            }
            
            //print(" \(count1) : \(historyEvents.count)")
            if count1 != historyEvents.count {
                return true
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
    
    internal func removeObserverWitheKye(_ key: Int) {
        observers.removeValue(forKey: key)
    }
    
    public func addChangeObserver(_ observer: ChangeObserver) -> StateObservationHandle {
        let count = observerCount
        observerCount += 1
        observers[count] = observer
        var handle: StateMachineObservationHandle<Int> = StateMachineObservationHandle<Int>(key: count)
        handle.removeClosure = {[weak self] key in
            if let i: Int = key {
                self?.removeObserverWitheKye(i)
            }
        }
        return handle
    }
    
    public var description: String {
        return "[State Machine: <\(self.dynamicType)> , current: \(self.currentState) , previous: \(self.previuosState), last event: \(self.lastEvent), total states: \(self.states.count)]"
    }
}
