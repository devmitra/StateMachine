//
//  StateMachine.swift
//  StateMachine
//
//  Created by Pushan Mitra on 12/07/16.
//  Copyright © 2016 Pushan Mitra. All rights reserved.
//

import Foundation

/*:
 # State Machine: Tutorial
 State machine is excelent concept of application development. Here whole application is composed into
 serveral unique states which is represented by state variable,(i.e. Store). Events triggered state transition. StateMachine framework provides excelent development tool to develop application based on state machine. This Swift (3.0) framework is a generic reusable code component. Generic represenattion of Event, StateIdentifier or StateName and State behavior can be achived through this frame work.
 
 #### Please build StateMachine project to run this tutorial 
 */

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
            return "\(type(of: self))"
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

public typealias StateNames = StateIdentifier


/**
 # State
 Structural And Behavioral Structure of States in State Machine. Basically states is behavioral represenation of state.
 1. Handle state operation As per events
 2. Update state variable or store
 3. Only applicable to the state machine with same type
 */
open class State<S: StateIdentifier,St, E: EventDescriptor>  {
    public typealias StateId = S
    public typealias Store = St
    public typealias Event  = E
    
    internal var state: StateId?
    
    public typealias Completion = (_ next : StateId, _ store: Store?) -> Void
    
    open var identifier: String {
        if let s: String = self.state?.rawValue as? String {
            return s
        }
        else {
            return "\(type(of: self))"
        }
    }
    
    public init(state: StateId) {
        self.state = state
    }
    
    open func operation(_ event: State.Event, _ store: State.Store?,_ data: Any? , _ completion: Completion) {
        
    }
    
    open func possibleNextStates() -> [StateId]? {
        return nil
    }
    
    
}


public enum StateMachineError: Error {
    case StartError, MachineError
}

//: Observation handler for state machine observation
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
 2. Handle Events: a genric event type conforming to EventDescription
 3. Accepts States with type same as own Event, StateName and Store type
 5. Perform state transition based on event handling by current state
 6. Store state variables
 7. Store Event History
 8. Store State Transition
 */
open class StateMachine <StateId: StateNames,Store, Event: EventDescriptor>: CustomStringConvertible {
    
    
    public typealias StateObj = State<StateId,Store,Event>
    public typealias StateAction = (Event,Store?,Any?,State<StateId,Store,Event>.Completion) -> Void
    public typealias ChangeObserver = (Event,StateId?,StateId,Store?) -> Void
    
    //: Hitory Tuple for state
    public typealias StateHistory = (state: StateId,time: Date);
    //: History Events
    public typealias EventHistory = (event:Event, time:Date);
    
    
    
    /*:
     ### Store
     Stored property to hold state variables
     */
    open var store: Store?
    
    /*:
     ### OperationQuue
     */
    internal var queue: OperationQueue?
    
    // Variables
    // Internal setter, open getter
    internal(set) open var currentState: StateId?
    
    internal var historyStates: [StateHistory] = [StateHistory]()
    internal var historyEvents: [EventHistory] = [EventHistory]()
    internal var observers: [Int : ChangeObserver] = [Int : ChangeObserver]()
    internal var observerCount: Int = 0
    internal var processing: Bool = false
    
    // Storing current State to history
    internal func storeCurrentStateToHistory() {
        if let c = self.currentState {
            historyStates.append((c, Date()))
        }
    }
    // Event completion function
    internal func completion(next: StateId, store: Any?) {
        //print("Complete ---- next \(next)")
        if let q: OperationQueue = self.queue {
            q.addOperation({ [weak self] in
                self?.processing = false
                if self?.currentState != next {
                    self?.storeCurrentStateToHistory()
                    self?.currentState = next
                    if let  s: Store = store as? Store {
                        self?.store = s
                    }
                    self?.sendChangeNotification(self?.previuosState, next)
                }
            })
        }
        else {
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
    }
    
    // State configuration array
    internal var states: [StateId : Any] = [StateId : Any]()
    
    internal func sendChangeNotification(_ previous: StateId?,_ next: StateId) {
        let uinfo:[NSObject : AnyObject] = [StateMachineKey as NSObject: self]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: StateMachineChangeNotification), object: nil, userInfo: uinfo)
        
        for (_,obsv) in observers {
            if let e: Event = self.lastEvent {
                obsv(e,previous,next,self.store)
            }
        }
    }
    
    // ### Default constrructor
    public init() {}
    
    // ### Constructor with operationQueue
    public init(queue: OperationQueue) {
        self.queue = queue
    }
    
    /**
     ### previousState
     */
    open var previuosState : StateId? {
        return historyStates.last?.state
    }
    
    /**
     ### lastEvent
            Last event processed by SM
    */
    open var lastEvent: Event? {
        return historyEvents.last?.event
    }
    
    /*!
     ### addState (Action)
     Adding a new state Closure based action to StateMachine
     */
    open func addState (_ state: StateId, _ item : Any) {
        if  item is StateAction {
            states[state] = item
        }
    }
    
    /*!
     ### addState (State)
     Adding a new state State object based operation to StateMachine. Only State of type Event,StateName and Store is accepted.
     */
    open func addState(_ configuration: State<StateId,Store,Event>) {
        if let stid : StateId = configuration.state {
            states[stid] = configuration
        }
    }
    
    /*!
     ### handleEvent
     Handling event associated with application.
     */
    open func handleEvent(_ event: Event,_ data: Any?) -> Bool {
        if processing {
            //print("processing")
            return !processing
        }
        
        if let current: StateId = self.currentState,let handle = states[current] {
            var accepted: Bool = false
            //print("get handel for \(currentState)")
            if let state: StateObj = handle as? StateObj {
                processing =  true
                accepted = true
                if let q: OperationQueue = self.queue {
                    historyEvents.append((event, Date()))
                    q.addOperation({ 
                        state.operation(event, self.store, data ,{ [weak self](next, store) in
                            self?.completion(next: next, store: store)
                            })
                    })
                }
                else {
                    historyEvents.append((event, Date()))
                    state.operation(event, self.store, data, { [weak self](next, store) in
                        self?.completion(next: next, store: store)
                    })
                }
                
                
            }
            else if let action: StateAction = handle as? StateAction {
                processing = true
                accepted = true
                if let q: OperationQueue = self.queue {
                    historyEvents.append((event, Date()))
                    q.addOperation({
                        action(event, self.store, data, {[weak self] (next, store) in
                            self?.completion(next: next, store: store)
                        })
                    })
                }
                else {
                    historyEvents.append((event, Date()))
                    action(event, self.store, data, {[weak self] (next, store) in
                        self?.completion(next: next, store: store)
                    })
                }
            }
            else {
                accepted = false
                processing = false
            }
            
            //print(" \(count1) : \(historyEvents.count)")
           return accepted
        }
        else {
            processing = false
        }
        return processing
    }
    
    open func start(state : StateId) throws -> Bool  {
        if let _ = currentState {
            return false
        }
        currentState = state
        return true
    }
    
    internal func removeObserverWitheKye(_ key: Int) {
        observers.removeValue(forKey: key)
    }
    
    open func addChangeObserver(_ observer: @escaping ChangeObserver) -> StateObservationHandle {
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
    
    open var description: String {
        return "[State Machine: <\(type(of: self))> , current: \(String(describing: self.currentState)) , previous: \(String(describing: self.previuosState)), last event: \(String(describing: self.lastEvent)), total states: \(self.states.count)]"
    }
    
    public var stateDiagram: String {
        var stateDiagram: String = "{State Machine}"
        for (stid , st) in self.states {
            if let state = st as? State<StateId, Store, Event>, let next: [StateId] = state.possibleNextStates() {
                stateDiagram.append("\n\t[\(stid)] ")
                for nextState in next {
                    stateDiagram.append("\n\t| -----> [\(nextState)]")
                }
            }
        }
        
        stateDiagram.append("\n{State Machine}")
        
        return stateDiagram
    }
    
    open func showHistory() -> Void {
       
    }
}
