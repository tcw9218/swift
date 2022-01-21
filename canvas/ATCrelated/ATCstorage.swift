
import Foundation
import CoreData
import UIKit
import CoreData

class ATCstorage : UIViewController{
    
    //MARK -- writestorage if id is exist then update
    var ATC_storageWriteImpl:@convention(c)(_ id : UInt16 , _ len : UInt16 ,_ dataIn : UnsafeMutablePointer<UInt8>?)->Int32 = {id,len,dataIn in
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<C_Storage>(entityName: "C_Storage")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        var entitiesCount = 0
        if let dataIn = dataIn {
              do {
                  entitiesCount = try context.count(for: fetchRequest)
                  if(entitiesCount == 0){   // first write
                      let core_1 = NSEntityDescription.insertNewObject(forEntityName: "C_Storage", into: context) as! C_Storage
                      core_1.id = Int32(id)
                      core_1.len = Int32(len)
                      core_1.c_data = Data(bytes: dataIn , count: Int(len))
                      do{
                          try context.save()
                          print("first write")
                          print("write \(core_1.id)")
                          //print(core_1)
                          return 1
                      }catch let createError{
                          print("Failed to first write :\(createError)")
                          return 0
                      }
                  }else{// update
                      do{
                          let dateInfoUpdate = try context.fetch(fetchRequest)
                          dateInfoUpdate[0].len = Int32(len)
                          dateInfoUpdate[0].c_data = Data(bytes: dataIn , count: Int(len))

                          do{
                              try context.save()
                              //print(dateInfoUpdate[0])
                              print("update \(dateInfoUpdate[0].id)")
                              
                              return 1
                          } catch let createError{
                              print("Failed to update: \(createError)")
                              return 0
                          }
                      }catch let fetchError{
                          print("Failed to fetch : \(fetchError)")
                          return 0
                      }
                  }
              }
              catch {
                  print("fetch error: \(error)")
                  return 0
              }
        }else{
            print("dataIn has problem")
            return 0
            
        }
    }

   //MARK: - readstorage didnt checck if exist
   var ATC_storageReadImpl:@convention(c)(_ id : UInt16 , _ len : UnsafeMutablePointer<UInt16>?  ,_ dataout : UnsafeMutablePointer<UInt8>?)->Int32 = {id, len , dataout in
       
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       if let dataout = dataout ,let len = len {
           let fetchRequestRead = NSFetchRequest<C_Storage>(entityName: "C_Storage")
           
           fetchRequestRead.predicate = NSPredicate(format: "id == %d", id )

               do{
                   let dateInfoRead = try context.fetch(fetchRequestRead)
                   //print(dateInfoRead[0].id)
                   if(dateInfoRead.count > 0){
                       //print(dateInfoRead.count)
                       len.pointee = UInt16 (dateInfoRead[0].len)
                       print(len.pointee)
                       var dataout =  dataout
                       for i in 0..<Int(len.pointee){
                           dataout[i] = (dateInfoRead[0].c_data!)[i]
                           
                       }
                       return 0
                   }else{
                       return 1
                   }
               }catch let fetchError{
                   print("Failed to fetch compaies: \(fetchError)")
                   return 1
               }
          
          }
       else{
           return 1
       }
   }
//MARK: - deletestorage
   var ATC_storageDeleteImpl:@convention(c)(_ id : UInt16) ->Int32 =
   {  id in
      
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       let fetchRequestDelete = NSFetchRequest<C_Storage>(entityName: "C_Storage")
       fetchRequestDelete.predicate = NSPredicate(format: "id == %d", id)

       do{
           let dateInfoDelete = try context.fetch(fetchRequestDelete)
           if(dateInfoDelete.count > 0){
           context.delete(dateInfoDelete[0])

           do{
               try context.save()
               print(dateInfoDelete[0])
               return 0
           } catch let createError{
               print("Failed to update: \(createError)")
               return 1
           }
           }else{
               print("id\(id) not exist")
               return 1
           }
       }catch {
           print("storage id not exist")
           //print("Failed to fetch compaies: \(fetchError)")
           return 1
       }
   }
   
   //MARK: - storagestate
   var ATC_storageStateImpl:@convention(c)(_ id : UInt16 , _ state : UnsafeMutablePointer<UInt8>?) ->Int32 =
   {   id , state in
           if let state = state {
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "C_Storage")
           fetchRequest.predicate = NSPredicate(format: "id = %d", id)
             fetchRequest.includesSubentities = false

           var entitiesCount = 0

             do {
                 entitiesCount = try context.count(for: fetchRequest)
                 if(entitiesCount == 0){
                     return 1
                 }else{
                     state[0] = 1
                     return 0
                 }
             }
             catch {
                 print("\(id)stage didnot exist: \(error)")
                 state[0] = 0
                 return 1
             }
           }else{
               state?[0] = 0
               return 1;
           }
  
   }

}
