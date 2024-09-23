//
//  Model.swift
//  TaskForJob
//
//  Created by PEPPA CHAN on 18.09.2024.
//

import Foundation

struct MainModel: Decodable{
    let todos: [Todos]
    let limit: Int
}
struct Todos: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
