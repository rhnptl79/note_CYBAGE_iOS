//
//  MoveNotesViewController.swift
//  note_CYBAGE_iOS
//
//  Created by user187410 on 2/3/21.
//

import UIKit
import CoreData

class MoveNotesViewController: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    
    var folders = [Folder]()
    var selectedNotes: [Note]? {
        didSet{
            loadFolders()
        }
    }
    
    //Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tblView.tableFooterView = UIView()

    }
    
    func loadFolders(){
        
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        //predicate
        let folderPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedNotes?[0].parentFolder?.name ?? "")
        request.predicate = folderPredicate
        
        do{
            folders = try context.fetch(request)
        }catch{
            print("Error fetching data \(error.localizedDescription)")
        }
    }
    
    //IB action method
    
    @IBAction func dismissVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MoveNotesViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = folders[indexPath.row].name
        cell.textLabel?.textColor = .black
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Move to \(folders[indexPath.row].name!)", message: "Are you Sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Move", style: .default) { (action) in
            for note in self.selectedNotes!{
                note.parentFolder = self.folders[indexPath.row]
            }
            //dismiss the vc
            self.performSegue(withIdentifier: "dismissMoveToVC", sender: self)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
//        noAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
//Doing Changes

}
