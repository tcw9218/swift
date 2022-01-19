//
//  tableTableViewController.swift
//  CD
//
//  Created by wu ted on 2021/12/23.
//

import UIKit
import CoreData

class informTableViewController: UITableViewController {

    
    var daemon : [ID_Storage] = []
    func getdaemon(){
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext{
            if let daemonFromCoreData = try? context.fetch(ID_Storage.fetchRequest()){
               // if let toDos = toDosFromCoreData as? [CDSave]{
                daemon = daemonFromCoreData
                    tableView.reloadData()
                    //print("count:\(todo.count)")
                    //print(todo[6])
                //}
            }
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("indexpath :\(indexPath)")
        let cell = UITableViewCell()
        let selectedDaemon = daemon[indexPath.row]
        print("selecdaemon:\(selectedDaemon.id)")
         //let id  = selectedToDo.id
        cell.textLabel?.text =  selectedDaemon.daemonid
        //print(cell.textLabel?.text)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
//    //MARK: - Delete
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//
//            let sA = storageAccess()
//
//            print( sA.deleteImpl(UInt16(todo[indexPath.row].id)))
//
//            todo.remove(at: indexPath.row)
//
//            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
//        }
//    }
//
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return daemon.count
    }
    override func viewDidLoad() {
        
        getdaemon()
        super.viewDidLoad()

    }
//    override func viewWillAppear(_ animated: Bool) {
//        getdaemon()
//        print("hhhh")
//    }



}

