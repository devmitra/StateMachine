//
//  ApplicationService.swift
//  StateMachine
//
//  Created by Pushan Mitra on 26/04/17.
//  Copyright © 2017 Pushan Mitra. All rights reserved.
//

import UIKit


typealias EditTodoTuple = (index: Int, value: String)

class Store {
    var list: [String] = [String]()
    var seletedTodoItem: Int = -1
}

var applicationStore: Store = Store()

enum ApplicationError: Error {
    case UnacceptedEvent
}

enum StateValue: String, StateNames {
    case Init, ViewTodoList, ViewTodo
}

enum TodoEvent: String, EventDescriptor {
    case Start,AddTodo, RemoveTodo, ViewTodo, EditTodo, BackToList
}

class StateInit: StateConfiguration<StateValue,Store,TodoEvent> {
    override func operation(_ event: Event, _ store: Store?, _ data: Any?, _ completion: (StateValue, Store?) -> Void) {
        if event == .Start {
            //applicationStore.list.append("add todo item by pressing +")
            completion(.ViewTodoList, applicationStore)
        }
        else {
            print("Unaccepted Event: \(event)")
            completion(.Init, nil)
            
        }
    }
    
    override func possibleNextStates() -> [StateValue]? {
        return [StateValue.ViewTodoList]
    }
}

class StateViewTodoList: StateConfiguration<StateValue,Store,TodoEvent> {
    override func operation(_ event: Event, _ store: Store?, _ data: Any?, _ completion: (StateValue, Store?) -> Void) {
        
        if let appStore: Store = store {
            switch event {
            case .AddTodo:
                appStore.list.append("Add new todo item")
                completion(.ViewTodoList, store)
            case .RemoveTodo:
                if appStore.list.count > 0, let index: Int = data as? Int,
                    index < appStore.list.count,
                    index >= 0 {
                    appStore.list.remove(at: index)
                }
                completion(.ViewTodoList, store)
            case .ViewTodo:
                if let index: Int = data as? Int,
                    index < appStore.list.count,
                    index >= 0 {
                    
                    appStore.seletedTodoItem = index
                    
                }
                completion(.ViewTodo, store)
            default:
                completion(.ViewTodoList, store)
            }
        }
    }
    
    override func possibleNextStates() -> [StateValue]? {
        return [.ViewTodo]
    }
}

class StateViewTodo: StateConfiguration<StateValue,Store,TodoEvent> {
    override func operation(_ event: Event, _ store: Store?, _ data: Any?, _ completion: (StateValue, Store?) -> Void) {
        if let appStore: Store = store {
            switch event {
            case .EditTodo:
                if appStore.seletedTodoItem != -1, let update: String = data as? String {
                    appStore.list[appStore.seletedTodoItem] = update
                }
                completion(.ViewTodo, appStore)
            case .BackToList:
                appStore.seletedTodoItem = -1
                completion(.ViewTodoList, store)
            default:
                completion(.ViewTodo, store)
            }
        }
    }
    
    override func possibleNextStates() -> [StateValue]? {
        return [.ViewTodoList]
    }
}

extension NSObject {
    var applicationService: TodoApplicationService {
        return TodoApplicationService.sharedService
    }
    
    var todoStore: Store {
        return applicationStore
    }
}


class TodoApplicationService: NSObject {
    
    private static var _sharedAppService: TodoApplicationService? = nil
    
    var stateMachine: StateMachine<StateValue,Store,TodoEvent>;
    
    
    var queue: OperationQueue = OperationQueue()
    
    func performOperation(_ block: @escaping () -> Swift.Void) {
        self.queue.addOperation(block);
    }
    
    
    public static var sharedService: TodoApplicationService {
        if let s = _sharedAppService {
            return s
        }
        else {
            let service = TodoApplicationService()
            _sharedAppService = service
            service.configState()
            return _sharedAppService!
        }
    }
    
    override init() {
        self.stateMachine =  StateMachine<StateValue,Store,TodoEvent>(queue: self.queue)
    }
    
    
    
    
    
    func configState()  {
        self.stateMachine.addState(StateInit(state:.Init))
        self.stateMachine.addState(StateViewTodoList(state:.ViewTodoList))
        self.stateMachine.addState(StateViewTodo(state:.ViewTodo))
        
        if !self.stateMachine.start(state: .Init) {
            print("Unable to start state machine")
        }
        else {
            print("State machine is up")
        }
        print("\(self.stateMachine.stateDiagram)")
        
    }
    

}
