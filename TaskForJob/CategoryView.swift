//
//  CategoryView.swift
//  TaskForJob
//
//  Created by PEPPA CHAN on 18.09.2024.
//

import SwiftUI

struct CategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDoData.id, ascending: true)],
        animation: .default)
    var todoData: FetchedResults<ToDoData>
    
    @State private var selectedView: Bool?
    @ObservedObject var connector: ViewsConnector
    
    var body: some View {
        HStack{
            Button {
                selectedView = nil
                connector.filter(category: selectedView, data: todoData)
            } label: {
                Text("All")
                    .foregroundColor(selectedView == nil ? Color.accentColor: Color.secondary)
                Text("\(String(describing: connector.limit))")
                    .padding(.horizontal, 9)
                    .background(selectedView == nil ? Color.accentColor: Color.secondary)
                    .foregroundColor(.white)
                    .clipShape(.capsule)
            }
            
            Text("|")
                .padding(.horizontal, 10)
                .foregroundColor(.secondary)
            
            Button {
                selectedView = true
                connector.filter(category: selectedView, data: todoData)
            } label: {
                Text("Open")
                    .foregroundColor(selectedView == true ? Color.accentColor: Color.secondary)
                Text("\(String(describing: connector.limit - connector.countTrue))")
                    .padding(.horizontal, 9)
                    .background(selectedView == true ? Color.accentColor: Color.secondary)
                    .foregroundColor(.white)
                    .clipShape(.capsule)
            }
            
            Button {
                selectedView = false
                connector.filter(category: selectedView, data: todoData)
            } label: {
                Text("Closed")
                    .foregroundColor(selectedView == false ? Color.accentColor: Color.secondary)
                Text("\(String(describing: connector.countTrue))")
                    .padding(.horizontal, 9)
                    .background(selectedView == false ? Color.accentColor: Color.secondary)
                    .foregroundColor(.white)
                    .clipShape(.capsule)
            }
            
            Spacer()
        }
    }
}

#Preview {
    CategoryView(connector: ContentView().connector).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
