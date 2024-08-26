//
//  DataManager.swift
//  Realm
//
//  Created by Анна Белова on 24.08.2024.
//

import Foundation

final class DataManager {
    static let shared = DataManager()
    
    private let storageManager = StorageManager.shared
    
    private init() {}
    
    func createTempData(completion: @escaping () -> Void) {
        let shoppingList = TaskList()
        shoppingList.title = "Shopping List"
        
        let moviesList = TaskList()
        moviesList.title = "Movies List"
        moviesList.date = Date()
        
        let milk = Task(value: ["Milk", "2L"])
        let apples = Task(value: ["Apples", "2Kg"])
        let bread = Task(value: ["title": "Bread", "isComplete": true])
        
        let firstFilm = Task(value: ["Best film ever"])
        let secondFilm = Task(value: ["The best of the best", "Must have", Date(), true])
        
        shoppingList.tasks.append(milk)
        shoppingList.tasks.insert(contentsOf: [apples, bread], at: 1)
        
        moviesList.tasks.insert(contentsOf: [firstFilm, secondFilm], at: 0)
        
        DispatchQueue.main.async { [unowned self] in
            storageManager.save([shoppingList, moviesList])
            completion()
        }
    }
}
