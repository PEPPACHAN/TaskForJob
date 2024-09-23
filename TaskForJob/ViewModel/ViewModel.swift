import Foundation
import SwiftUI

class Todo {
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    func fetchTodo(completion: @escaping (MainModel?, Error?) -> ()) {
        let task = session.dataTask(with: URL(string: "https://dummyjson.com/todos")!) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("No response")
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response"]))
                return
            }
            if response.statusCode > 299 {
                print("Response isn't OK")
                completion(nil, NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Response isn't ok"]))
                return
            }
            guard let data = data else {
                print("No data")
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"]))
                return
            }
            DispatchQueue.main.async {
                do {
                    let result = try JSONDecoder().decode(MainModel.self, from: data)
                    completion(result, nil)
                } catch {
                    print("Decoding error: \(error)")
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}

class ViewsConnector: ObservableObject {
    @Published var countTrue: Int16 = 0
    @Published var limit: Int16 = 0
    @Published var categoryChoice: Bool?
    @Published var filteredData: [ToDoData] = []
    
    func filter(category: Bool?, data: FetchedResults<ToDoData>) {
        self.categoryChoice = category
        
        DispatchQueue.global(qos: .userInitiated).async {
            var filtered: [ToDoData]
            
            if let choice = self.categoryChoice {
                filtered = data.filter { $0.status == choice }
            } else {
                filtered = Array(data)
            }
            
            filtered.sort {
                if let firstTimestamp = $0.timestamp, let secondTimestamp = $1.timestamp {
                    return firstTimestamp > secondTimestamp
                }
                return false
            }
            
            DispatchQueue.main.async {
                self.filteredData = filtered
            }
        }
    }
}
