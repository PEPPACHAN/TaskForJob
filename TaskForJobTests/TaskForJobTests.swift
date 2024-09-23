//
//  TaskForJobTests.swift
//  TaskForJobTests
//
//  Created by PEPPA CHAN on 23.09.2024.
//

import XCTest
@testable import TaskForJob

class MockURLSessionDataTask: URLSessionDataTask{
    override func resume() {}
}

class MockURLSession: URLSession{
    var mockData: Data?
    var mockError: Error?
    var mockResponse: URLResponse?
    
    override func dataTask(with request: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(mockData, mockResponse, mockError)
        return MockURLSessionDataTask()
    }
}

final class TaskForJobTests: XCTestCase {
    var connector: ViewsConnector!
    
    override func setUp() {
        super.setUp()
        connector = ViewsConnector()
    }
    override func tearDown() {
        connector = nil
        super.tearDown()
    }
    
    func testFilterMethod(){    // MARK: Тест для проверки метода фильтрации данных
        
    }
    
    func testTodoFetchDataSuccess(){    // MARK: Тест для проверки декодинга данных
        let mockSession = MockURLSession()
        let jsonData = """
                        {
                            "todos": [
                                {
                                    "id": 1,
                                    "todo": "Do something nice for someone you care about",
                                    "completed": false,
                                    "userId": 152
                                },
                                {
                                    "id": 2,
                                    "todo": "Memorize a poem",
                                    "completed": true,
                                    "userId": 13
                                }
                            ],
                            "total": 254,
                            "skip": 0,
                            "limit": 2
                        }
                        """.data(using: .utf8)
        mockSession.mockData = jsonData
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://dummyjson.com/todos")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        let todo = Todo(session: mockSession)
        let expectation = self.expectation(description: "Fetch Todo Success")
        
        todo.fetchTodo{ (data, error) in
            XCTAssertNil(error)     // Проверяем, что ошибок нет
            XCTAssertNotNil(data)   // Проверяем, что данные не пустые
            XCTAssertEqual(data?.todos.count, 2)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testTodoFetchDataFailure() {   // MARK: Тест для проверки ошибки
        let mockSession = MockURLSession()
        mockSession.mockError = NSError(domain: "", code: 404, userInfo: nil)
        
        let expectation = self.expectation(description: "Fetch Todo Failure")
        let todo = Todo(session: mockSession)
        
        todo.fetchTodo { data, error in
            XCTAssertNil(data)       // Проверяем, что данных нет
            XCTAssertNotNil(error)   // Проверяем, что ошибка не пустая
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testTodoResponseFailure() {   // MARK: Тест для проверки ошибки респонза
        let mockSession = MockURLSession()
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://dummyjson.com/todos")!,
                                                   statusCode: 400,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        
        let expectation = self.expectation(description: "Fetch Todo 404 response")
        let todo = Todo(session: mockSession)
        
        todo.fetchTodo { data, error in
            XCTAssertNil(data)       // Проверяем, что данных нет
            XCTAssertNotNil(error)   // Проверяем, что ошибки не пустые
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testTodoDecodingFailure() {   // MARK: Тест для проверки ошибки декодинга
        let mockSession = MockURLSession()
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://dummyjson.com/todos")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        mockSession.mockData = "".data(using: .utf8)
        
        let expectation = self.expectation(description: "Fetch Todo deecoding error")
        let todo = Todo(session: mockSession)
        
        todo.fetchTodo { data, error in
            XCTAssertNil(data)       // Проверяем, что данных нет
            XCTAssertNotNil(error)   // Проверяем, что ошибки не пустые
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testTodoDataEmpty() {   // MARK: Тест для проверки отсутсвия данных
        let mockSession = MockURLSession()
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://dummyjson.com/todos")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        mockSession.mockData = nil
        
        let expectation = self.expectation(description: "Fetch Todo data empty")
        let todo = Todo(session: mockSession)
        
        todo.fetchTodo { data, error in
            XCTAssertNil(data)       // Проверяем, что данных нет
            XCTAssertNotNil(error)   // Проверяем, что ошибки не пустые
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testTodoResponseEmpty() {   // MARK: Тест для проверки ошибки респонза
        let mockSession = MockURLSession()
        mockSession.mockResponse = nil
        
        let expectation = self.expectation(description: "Fetch Todo no response")
        let todo = Todo(session: mockSession)
        
        todo.fetchTodo { data, error in
            XCTAssertNil(data)       // Проверяем, что данных нет
            XCTAssertNotNil(error)   // Проверяем, что ошибки не пустые
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
}
