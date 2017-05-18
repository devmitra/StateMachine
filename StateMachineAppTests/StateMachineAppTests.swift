//
//  StateMachineAppTests.swift
//  StateMachineAppTests
//
//  Created by Pushan Mitra on 28/04/17.
//  Copyright © 2017 Pushan Mitra. All rights reserved.
//

import XCTest
@testable import StateMachineApp

class StateMachineAppTests: XCTestCase {
    
    let app: NumberAddApp = NumberAddApp()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app.configureStateMachine()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExpressionToInt()  {
        let numStore: NumberAddStore = NumberAddStore()
        let sum = numStore.expressionToInt(exp: "12 +25+51")
        XCTAssert(sum == 88)
        
    }
    
    func testAddWithoutExplictAsync() {
        let expectation:XCTestExpectation  = self.expectation(description: "AddEventTest2")
        
        OperationQueue.main.addOperation {
            print(" 1 ****\(self.app.stateMachine)")
            let expr = "12+45+ 56+ 78"
            let _: Bool = self.app.stateMachine.handleEvent(.AddExpression, expr)
            
            self.app.performOperation {
                print(" 2 ****\(self.app.stateMachine)")
                let store = self.app.store!
                print("\(store.expressionItems)")
                if let last: String = self.app.store?.expressionItems.last {
                    print("****last:\(last)")
                    XCTAssert(last == expr)
                    expectation.fulfill()
                    
                }
                else {
                    XCTFail()
                    expectation.fulfill()
                    
                }
            }
        }
        
        self.waitForExpectations(timeout: 2.0) { (e: Error?) in
            print("Error: \(e)")
            //XCTFail()
        }
    }
    
    func testRemove()  {
        let expectation:XCTestExpectation  = self.expectation(description: "Remove")
        
        OperationQueue.main.addOperation {
            let expr = "99+56+7"
            let _: Bool = self.app.stateMachine.handleEvent(.AddExpression, expr)
            
            self.app.performOperation {
                
                let store = self.app.store!
                print("\(store.expressionItems)")
                if let last: String = self.app.store?.expressionItems.last {
                    
                    XCTAssert(last == expr)
                    
                    let index = self.app.store?.expressionItems.index(of: expr)
                    XCTAssert(index != nil)
                    
                    let _ = self.app.stateMachine.handleEvent(.RemoveExpression, index)
                    
                    self.app.performOperation {
                        print("Remove : \(store.expressionItems)")
                        print("---- \(self.app.store?.expressionItems.index(of: expr))")
                        let cond: Bool = self.app.store?.expressionItems.index(of: expr) == nil
                        print("Cond: \(cond)")
                        XCTAssert(cond)
                        expectation.fulfill()
                    }
                    
                }
                else {
                    XCTFail()
                    expectation.fulfill()
                    
                }
            }
        }
        
        self.waitForExpectations(timeout: 2.0) { (e: Error?) in
            print("Error: \(e)")
            //XCTFail()
        }
    }
    
    func testEditAndUpdate()  {
        let expectation:XCTestExpectation  = self.expectation(description: "Edit")
        
        OperationQueue.main.addOperation {
            let expr = "12+45+ 56+ 78"
            let _: Bool = self.app.stateMachine.handleEvent(.AddExpressions, [expr, "11+89+90"])
            
            self.app.performOperation {
                
                let store = self.app.store!
                print("\(store.expressionItems)")
                if let last: String = self.app.store?.expressionItems.last {
                    
                    XCTAssert(last == "11+89+90")
                    
                    let _ = self.app.stateMachine.handleEvent(.EditExpression, 0)
                    
                    self.app.performOperation {
                        XCTAssert(self.app.store?.currentExpressionIndex ==  0)
                        let expr2 = "78+67+78"
                        let _ = self.app.stateMachine.handleEvent(.UpdateExpression, expr2)
                        
                        self.app.performOperation {
                            XCTAssert(self.app.store?.expressionItems[0] == expr2)
                            expectation.fulfill()
                        }
                    }
                    
                }
                else {
                    XCTFail()
                    expectation.fulfill()
                    
                }
            }
        }
        
        self.waitForExpectations(timeout: 2.0) { (e: Error?) in
            print("Error: \(e)")
            //XCTFail()
        }
    }
    
    func testEventAdd() {
        let expectation:XCTestExpectation  = self.expectation(description: "AddEventTest")
        OperationQueue.main.addOperation {
            let expr = "12+45+ 56+ 78"
            self.app.performOperation {
                
                let _: Bool = self.app.stateMachine.handleEvent(.AddExpression, expr)
            }
            OperationQueue.main.addOperation {
                self.app.performOperation {
                    let store = self.app.store!
                    print("\(store.expressionItems)")
                    if let last: String = self.app.store?.expressionItems.last {
                        print("****last:\(last)")
                        XCTAssert(last == expr)
                        expectation.fulfill()
                        
                    }
                    else {
                        print("gaya")
                        XCTFail()
                        expectation.fulfill()
                        
                    }
                }
            }
        }
        
        
        self.waitForExpectations(timeout: 2.0) { (e: Error?) in
            print("Error: \(e)")
            //XCTFail()
        }
    }
    
    
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
