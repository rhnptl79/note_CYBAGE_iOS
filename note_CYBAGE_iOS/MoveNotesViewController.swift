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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}