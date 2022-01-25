
//IDstorage.swift
// canvas
//
// Created by wu ted on 2022/1/7.


import Foundation
import CoreData
import UIKit

class IDstorage : UIViewController{

    func setDaemon( daemon_in : String ){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<ID_Storage>(entityName: "ID_Storage")

        fetchRequest.predicate = NSPredicate(format: "daemonid == %@", daemon_in)
        var entitiesCount = 0
        do {
            entitiesCount = try context.count(for: fetchRequest)
             if(entitiesCount == 0){   // first write
                 let core_1 = NSEntityDescription.insertNewObject(forEntityName: "ID_Storage", into: context) as! ID_Storage
                 core_1.daemonid = daemon_in
                 do{
                     try context.save()
                     print("first write daemon")
                     //print(core_1)

                 }catch let createError{
                     print("Failed to first write daemon :\(createError)")

                 }
             }else{// update
                     do{
                         let dateInfoUpdate = try context.fetch(fetchRequest)
                         dateInfoUpdate[0].daemonid = daemon_in
                         
                         do{
                             try context.save()
                             //print(dateInfoUpdate[0])
                             print("update daemon")

                         } catch let createError{
                             print("Failed to update daemon: \(createError)")
                         }
                     }catch let fetchError{
                         print("Failed to update daemon fetch : \(fetchError)")
                     }
                 }
             }
             catch {
                 print("fetch error: \(error)")

             }
         }
    
    func deleteDaemon(daemonid: String?){
       
        if let daemonid = daemonid {
             let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
             let fetchRequestDelete = NSFetchRequest<ID_Storage>(entityName: "ID_Storage")
             fetchRequestDelete.predicate = NSPredicate(format: "daemonid == %@", daemonid)

             do{
                 let dateInfoDelete = try context.fetch(fetchRequestDelete)
                 if(dateInfoDelete.count > 0){
                     context.delete(dateInfoDelete[0])

                     do{
                         try context.save()
                         //print(dateInfoDelete[0])
                         print("delete daemon id")
                       
                     } catch let createError{
                         print("Failed to update: \(createError)")
                        
                     }
                 }
             }catch{
                 print("daemon_id not exist cant delete")
             }
        }else{
            print("daemonid null")
        }
        
    }
}
