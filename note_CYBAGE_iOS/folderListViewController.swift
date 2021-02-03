//
//  folderListViewController.swift
//  note_CYBAGE_iOS
//
//  Created by user187410 on 2/3/21.
//

import UIKit
import CoreData

class folderListViewController: UITableViewController {
    
    var folders = [Folder]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.tableFooterView = UIView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getFolderFromDataBase()
        tableView.reloadData()
    }
    
    //Mark: - Get all folders from the databse.
    func getFolderFromDataBase()
    {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        do{
            folders = try context.fetch(request)
        }catch{
            print("Error Loading Folders \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    
    //MARK: - showAlert func
    func showAlert() {
        let alert = UIAlertController(title: "Name taken", message: "Please Choose Another Name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Save Folder Func
    func saveFolders() {
        do{
            try context.save()
            tableView.reloadData()
        }catch{
            print("Erro saving the folder \(error.localizedDescription)")
        }
    }
    
    //MARK:- Action Method
    
    
    @IBAction func addFolderBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Folder", message: "Please give a name", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "ADD", style: .default) { (action) in
            let folderNames = self.folders.map{$0.name?.lowercased()}
            guard !folderNames.contains(textField.text?.lowercased()) else {self.showAlert(); return}
            let newFolder = Folder(context: self.context)
            newFolder.name = textField.text!
            self.folders.append(newFolder)
            self.saveFolders()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Please Provide folder name"
        }
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! NoteListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destination.selectedFolder = folders[indexPath.row]
        }

    }
}

//MARK: - Table View Data Source

extension folderListViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folder_cell", for: indexPath)
        cell.textLabel?.text = folders[indexPath.row].name
        cell.detailTextLabel?.text = "\(folders[indexPath.row].notes?.count ?? 0)"
        cell.imageView?.image = UIImage(systemName: "folder")
        cell.selectionStyle = .none
        return cell
    }
    
}
