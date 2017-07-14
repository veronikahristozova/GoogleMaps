//
//  RealmManager.swift
//  GoogleMapsxAllterco
//
//  Created by Veronika Hristozova on 7/13/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    
    let realm: Realm? = {
        do {
            let realm = try Realm()
            return realm
        } catch {
            print("Could not init realm")
            return nil
        }
    }()
    
    /// Saving Object to Realm
    ///
    /// - Parameter obj: the object to save
    func saveObject(_ obj: Object, completion: ((Bool) -> Void)?) {
        DispatchQueue.main.async {
            do {
                try self.realm?.write({
                    // If update = true, objects that are already in the Realm will be
                    // updated instead of added a new.
                    self.realm?.add(obj, update: true)
                    completion?(true)
                })
            } catch {
                print("Realm: Could not add object")
                completion?(false)
            }
        }
    }
    
    
    /// Retrieving all objects, previously saved
    ///
    /// - Returns: the objects
    func getObjects() -> Results<Marker>? {
        return realm?.objects(Marker.self)
    }
    
    
    /// Function for retrieving single object by ID
    ///
    /// - Parameter id: the id of the object
    /// - Returns: the object found by id if existing
    func getObjectByID(id: String) -> Marker? {
        return realm?.objects(Marker.self).filter { $0.id == id }.first
    }
    
    func deleteObjectByID(id: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            if let objectToDelete = self.getObjectByID(id: id) {
                do {
                    try self.realm?.write {
                        self.realm?.delete(objectToDelete)
                        completion(true)
                    }
                } catch {
                    print("Realm: Could not delete object with id: \(id)")
                    completion(false)
                }
            }
        }
    }
}
