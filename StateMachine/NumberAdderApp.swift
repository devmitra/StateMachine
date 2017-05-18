//
//  NumberAdderApp.swift
//  StateMachine
//
//  Created by Pushan Mitra on 28/04/17.
//  Copyright © 2017 Pushan Mitra. All rights reserved.
//

import UIKit

typealias NumberAddState = StateConfiguration<NumberAddStates,NumberAddStore,NumberAddEvents>


public enum NumberAddStates: String, StateNames {
    case Init, MainView
}

public enum NumberAddEvents: String, EventDescriptor {
    case Start,AddExpression, AddExpressions, RemoveExpression,EditExpression, UpdateExpression,CurrentExpression, Clear
}

enum NumerAddAppError: Error {
}

public class NumberAddStore {
    var expressionItems: [String] = [String]()
    var currentExpressionIndex: Int = -1
    var currentExpression: String = ""
    
    func expressionToInt(exp: String) -> Double {
        var result = 0.0
        let nums: [String] = exp.components(separatedBy: "+")
        for numStr in nums {
            let cleanStr: String = numStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let num: Double =  Double((cleanStr as NSString).doubleValue)
            result = result + num
        }
        return result
    }
    
    var total: Double {
        var result: Double =  0
        for expr in  expressionItems {
            result = result + self.expressionToInt(exp: expr)
        }
        return result
    }
    
}

var globalStore: NumberAddStore = NumberAddStore()

class NumberAddStateInit: StateConfiguration<NumberAddStates,NumberAddStore,NumberAddEvents> {
    override func operation(_ event: NumberAddEvents, _ store: NumberAddStore?, _ data: Any?, _ completion: (NumberAddStates, NumberAddStore?) -> Void) {
        if event == .Start {
            completion(.MainView, globalStore )
        }
        else {
            print("Unaccepted Event: \(event) for state : \(String(describing: self.state))")
            completion(.Init, nil)
            
        }
    }
    
    override func possibleNextStates() -> [NumberAddStates]? {
        return [.MainView]
    }
}

class NumberAddStateMainView: NumberAddState {
    override func operation(_ event: NumberAddEvents, _ store: NumberAddStore?, _ data: Any?, _ completion: (NumberAddStates, NumberAddStore?) -> Void) {
        
        if let appStore = store {
            switch event {
            case .AddExpression:
                if let dat: String = data as? String {
                    appStore.expressionItems.append(dat)
                    appStore.currentExpressionIndex = appStore.expressionItems.count - 1
                }
            case .AddExpressions:
                if let exprs: [String] = data as? [String] {
                    appStore.expressionItems.append(contentsOf: exprs)
                }
            case .EditExpression:
                if let index: Int = data as? Int, index >= 0, index < appStore.expressionItems.count {
                    appStore.currentExpressionIndex = index
                    appStore.currentExpression = appStore.expressionItems[index]
                }
                
            case .RemoveExpression:
                if let index: Int = data as? Int, index >= 0, index < appStore.expressionItems.count {
                    appStore.expressionItems.remove(at: index)
                    if appStore.currentExpressionIndex == index {
                        appStore.currentExpressionIndex = -1
                    }
                }
               
            case .UpdateExpression:
                if let newExpr: String = data as? String, appStore.currentExpressionIndex != -1 {
                    appStore.expressionItems[appStore.currentExpressionIndex] = newExpr
                    appStore.currentExpression = newExpr
                }
            case .CurrentExpression:
                if let newExpr: String = data as? String {
                    appStore.currentExpression = newExpr
                    
                }
            case .Clear:
                appStore.currentExpression = ""
                appStore.currentExpressionIndex = -1
            default:
                print("Unaccepted Event: \(event)")
                
            }
            
            completion(.MainView, appStore)
        }
        else {
            print("No Store: \(event)")
            completion(.MainView, nil)
        }
        
    }
    
    override func possibleNextStates() -> [NumberAddStates]? {
        return [.MainView]
    }
}



extension NSObject {
    var numberAddApp: NumberAddApp {
        return NumberAddApp.appService()
    }
}



extension NSObject  {
    
}


class NumberAddApp : ApplicationService<NumberAddStates, NumberAddStore,NumberAddEvents,NumerAddAppError> {
    
    static var _appservice: NumberAddApp?
    
    var isEditMode: Bool {
        return self.stateMachine.lastEvent == NumberAddEvents.EditExpression || self.stateMachine.lastEvent == NumberAddEvents.UpdateExpression
    }
    
    override open class func appService()-> NumberAddApp {
        if let apps = _appservice {
            return apps
        } else {
            let appservice: NumberAddApp = NumberAddApp()
            appservice.configureStateMachine()
            _appservice = appservice
            return appservice
        }
    }
    
    
    override func configureStateMachine() {
        self.stateMachine.addState(NumberAddStateInit(state: .Init))
        self.stateMachine.addState(NumberAddStateMainView(state: .MainView))
        
        let _ = self.stateMachine.start(.Init, .Start)
        
        print(" ** Number Add State Machin ** \(self.stateMachine.stateDiagram)")
        
    }
}


