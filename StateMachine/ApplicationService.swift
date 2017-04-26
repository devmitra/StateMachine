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
}

var applicationStore: Store = Store()

enum ApplicationError: Error {
    case UnacceptedEvent
}

enum StateValue: String, StateNames {
    case Init, ViewTodoList, ViewTodo
}

enum Event: String, EventDescriptor {
    case Start,AddTodo, RemoveTodo, ViewTodo, EditTodo, BackToList
}

class StateInit: State<StateValue,Store,Event> {
    override func operation(_ event: Event, _ store: Store?, _ data: Any?, _ completion: (StateValue, Store?) -> Void) {
        if event == .Start {
            completion(.ViewTodo, applicationStore)
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

class StateViewTodoList: State<StateValue,Store,Event> {
    override func operation(_ event: Event, _ store: Store?, _ data: Any?, _ completion: (StateValue, Store?) -> Void) {
        
        if let appStore: Store = store {
            switch event {
            case .AddTodo:
                appStore.list.append("Add new todo item")
                completion(.ViewTodoList, store)
            case .RemoveTodo:
                if appStore.list.count > 0, let index: Int = data as? Int, index < appStore.list.count, index >= 0 {
                    appStore.list.remove(at: index)
                }
                completion(.ViewTodoList, store)
            case .ViewTodo:
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

class StateViewTodo: State<StateValue,Store,Event> {
    override func operation(_ event: Event, _ store: Store?, _ data: Any?, _ completion: (StateValue, Store?) -> Void) {
        if let appStore: Store = store {
            switch event {
            case .EditTodo:
                if let updateVal: EditTodoTuple = data as? EditTodoTuple, updateVal.index >= 0, updateVal.index < appStore.list.count {
                    
                }
            case .BackToList:
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


class ApplicationService: NSObject {
    var stateMachine: StateMachine<StateValue,Store,Event> = StateMachine<StateValue,Store,Event>(queue: OperationQueue.main)
    
    func configState()  {
        self.stateMachine.addState(StateInit(state:.Init))
        self.stateMachine.addState(StateViewTodoList(state:.ViewTodoList))
        self.stateMachine.addState(StateViewTodo(state:.ViewTodo))
        
        print("\(self.stateMachine.stateDiagram)")
        
    }
    

}
