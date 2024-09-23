//
//  ContentView.swift
//  TaskForJob
//
//  Created by PEPPA CHAN on 18.09.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDoData.id, ascending: true)],
        animation: .default)
    private var todoData: FetchedResults<ToDoData>
    
    private let formattedTitle: String = {
        let format = DateFormatter()
        format.dateFormat = "EEEE, d MMMM"
        return format.string(from: Date())
    }()
    
    @State private var isNewTask = false
    @State private var editName = ""
    @State private var editDescription = ""
    @StateObject var connector = ViewsConnector()
    
    var body: some View {
        VStack(spacing: 10) {
            HStack{
                VStack{
                    Text("Today's Task")
                        .font(.title)
                        .bold()
                    Text(formattedTitle)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    isNewTask.toggle()
                } label: {
                    Text("+  NewTask")
                        .frame(width: 110)
                        .bold()
                        .padding(10)
                        .background(Color.accentColor.opacity(0.2))
                        .clipShape(.buttonBorder)
                }
            }
            .padding()
            CategoryView(connector: connector)
                .padding()
            
            ScrollView{
                if !todoData.isEmpty{
                    TodoPlates(connector: connector)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .background(Color.secondary.opacity(0.1))
        .onAppear{
            DispatchQueue(label: "ru.emirovakhmed.async").async {
                if todoData.isEmpty{
                    saveData()
                }
                connector.filter(category: nil, data: todoData)
            }
        }
        .sheet(isPresented: $isNewTask) {
            VStack(alignment: .leading, spacing: 10){
                Button {
                    if (editName != "") && (editDescription != ""){
                        newTask(name: editName, description: editDescription)
                        editName = ""
                        editDescription = ""
                        isNewTask.toggle()
                    }
                    else{
                        editName = ""
                        editDescription = ""
                        isNewTask.toggle()
                    }
                } label: {
                    Text("Done")
                }
                .frame(width: UIScreen.main.bounds.width - 50, height: 30, alignment: .trailing)
                TextField("Input task name", text: $editName)
                    .padding()
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                TextField("Input task description", text: $editDescription)
                    .padding()
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                Spacer()
            }
            .onSubmit {
                newTask(name: editName, description: editDescription)
                isNewTask.toggle()
            }
            .padding()
        }
    }
}

extension ContentView{
    private func saveData(){
        Todo().fetchTodo { data, error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let data = data{
                viewContext.performAndWait {
                    for item in data.todos{
                        let newItems = ToDoData(context: viewContext)
                        newItems.id = UUID()
                        newItems.taskName = item.todo
                        newItems.taskDescription = String(item.userId)
                        newItems.status = item.completed
                        newItems.timestamp = Date()
                        newItems.limit = Int16(data.limit)
                        do{
                            try viewContext.save()
                        }catch{
                            print(error.localizedDescription)
                        }
                    }
                }
                connector.filter(category: nil, data: todoData)
            }
        }
    }
    
    private func newTask(name: String, description: String){
        let newItem = ToDoData(context: viewContext)
        newItem.taskName = name
        newItem.taskDescription = description
        newItem.id = UUID()
        newItem.limit = connector.limit + 1
        newItem.timestamp = Date()
        newItem.status = false
        do{
            try viewContext.save()
        }catch{
            print("cannot save new task")
        }
        connector.limit = Int16(todoData.count + 1)
        connector.filter(category: connector.categoryChoice, data: todoData)
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
