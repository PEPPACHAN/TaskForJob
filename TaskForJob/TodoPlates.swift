//
//  TodoPlates.swift
//  TaskForJob
//
//  Created by PEPPA CHAN on 18.09.2024.
//

import SwiftUI

struct TodoPlates: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDoData.timestamp, ascending: false)],
        animation: .default)
    private var todoData: FetchedResults<ToDoData>
    
    @State private var editName: String = ""
    @State private var editDescription: String = ""
    @ObservedObject var connector: ViewsConnector
    @State private var editing = false
    
    private var buttonContainerWidth = UIScreen.main.bounds.width - 50
    private var buttonContainerHeight: CGFloat = 30
    @State private var isPresented:ToDoData?
    
    init(connector: ViewsConnector) {
        self.connector = connector
    }
    
    var body: some View {
        ForEach(connector.filteredData){ item in
            VStack(alignment: .leading){
                HStack{
                    VStack(alignment: .leading){
                        Text(item.taskName ?? "unknown")
                            .font(.title3)
                            .strikethrough(item.status)
                            .lineLimit(2)
                        Text(item.taskDescription ?? "unknown")
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Button {
                        viewContext.perform {
                            item.status.toggle()
                            if item.status{
                                connector.countTrue+=1
                            }else{
                                connector.countTrue-=1
                            }
                            do{
                                try viewContext.save()
                            }catch{
                                print(error.localizedDescription)
                            }
                        }
                    } label: {
                        Image(systemName: item.status ? "checkmark.circle.fill":"circle")
                            .foregroundColor(item.status ? Color.accentColor: Color.secondary)
                            .font(.title2)
                    }
                }
                Divider()
                HStack{
                    let formattedCreation: String = {
                        let format = DateFormatter()
                        format.dateFormat = "d MMMM"
                        return format.string(from: item.timestamp ?? Date())
                    }()
                    let formattedNow: String = {
                        let format = DateFormatter()
                        format.dateFormat = "d MMMM"
                        return format.string(from: Date())
                    }()
                    let formattedCreationTime: String = {
                        let format = DateFormatter()
                        format.dateFormat = "HH:mm"
                        return format.string(from: item.timestamp ?? Date())
                    }()
                    
                    Text(formattedNow == formattedCreation ? "Today": formattedCreation)
                    Text("\(formattedCreationTime)")
                        .foregroundColor(.secondary)
                }
                .font(.footnote)
            }
            .onTapGesture {
                isPresented = item
            }
            .onAppear{
                var count: Int16 = 0
                for i in todoData{
                    if i.status{
                        count+=1
                    }
                }
                connector.countTrue = count
                connector.limit = Int16(todoData.count)
            }
            .sheet(item: $isPresented, onDismiss: {editing = false}){ item in
                
                let sheetFormatedDate: String = {
                    let format = DateFormatter()
                    format.dateFormat = "EEEE, d MMMM"
                    return format.string(from: item.timestamp ?? Date())
                }()
                
                if editing{
                    VStack(alignment: .leading){
                        Button {
                            if (editName != "") && (editDescription != ""){
                                viewContext.perform {
                                    print(1)
                                    item.taskName = editName
                                    item.taskDescription = editDescription
                                    print(item.taskName!, item.taskDescription!)
                                    do{
                                        try viewContext.save()
                                    }catch{
                                        print("cannot save edited data")
                                    }
                                }
                                editing.toggle()
                            }
                            else{
                                editing.toggle()
                            }
                        } label: {
                            Text("Done")
                        }
                        .frame(width: buttonContainerWidth, height: buttonContainerHeight, alignment: .trailing)
                        VStack(alignment: .leading, spacing: 10){
                            TextField(item.taskName ?? "Task name is empti", text: $editName)
                                .padding()
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.secondary.opacity(0.5))
                                }
                            TextField(item.taskDescription ?? "Description is empty", text: $editDescription)
                                .padding()
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.secondary.opacity(0.5))
                                }
                        }
                        .padding()
                        Spacer()
                    }
                    .padding()
                }else{
                    VStack{
                        Button {
                            editName = item.taskName ?? ""
                            editDescription = item.taskDescription ?? ""
                            editing.toggle()
                        } label: {
                            Text("Edit")
                        }
                        .frame(width: buttonContainerWidth, height: buttonContainerHeight, alignment: .trailing)
                        
                        VStack(alignment: .leading, spacing: 10){
                            Text(item.taskName ?? "Unknown")
                                .font(.title)
                            Text(item.taskDescription ?? "Unknown")
                                .font(.subheadline)
                            Text(String(sheetFormatedDate))
                                .font(.caption)
                            Spacer()
                        }
                        Button {
                            viewContext.delete(item)
                            do{
                                try viewContext.save()
                            }catch{
                                print("Cannot delete item")
                            }
                            connector.limit-=1
                            connector.filter(category: connector.categoryChoice, data: todoData)
                            isPresented = nil
                        } label: {
                            Text("Delete")
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(.buttonBorder)
        }
    }
}

#Preview {
    TodoPlates(connector: ContentView().connector).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
