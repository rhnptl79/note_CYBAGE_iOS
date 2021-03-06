//
//  NoteListViewController.swift
//  note_CYBAGE_iOS
//
//  Created by user187410 on 2/3/21.
//

import UIKit
import  CoreData

class NoteListViewController: UITableViewController {

    @IBOutlet weak var trashBtn: UIBarButtonItem!
    
    @IBOutlet weak var moveBtn: UIBarButtonItem!
    
    var deletingMovingOption: Bool = false
    var notes = [Note]()
    
    var selectedFolder: Folder? {
        didSet{
            loadNotes()
        }
    }
    
    //Create context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSearchBar()
        tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //MARK:- Action Methods
    
    @IBAction func trashBtnPressed(_ sender: UIBarButtonItem) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let rows = (indexPaths.map {$0.row}).sorted(by: >)
            let _ = rows.map { deleteNote(note: notes[$0])}
            let _ = rows.map {notes.remove(at: $0)}
            tableView.reloadData()
            saveNotes()
        }
    }
    
    @IBAction func moveBtnPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "NoteListToMoveFolder", sender: self)
    }
    
    
    @IBAction func backBtnTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editingBtnPressed(_ sender: UIBarButtonItem) {
        deletingMovingOption = !deletingMovingOption
        trashBtn.isEnabled = !trashBtn.isEnabled
        moveBtn.isEnabled = !moveBtn.isEnabled
        tableView.setEditing(deletingMovingOption, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note_cell", for: indexPath)
        
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        
        let backgroundView = UIView()
//        backgroundView.backgroundColor = .darkGray
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = notes[indexPath.row]
            self.deleteNote(note: note)
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        else if editingStyle == .insert {
        }
    }
    
    //MARK: - Load Notes func
    func loadNotes(predicate:NSPredicate? = nil){
        
        let request:NSFetchRequest<Note> = Note.fetchRequest()
        let folderPredicate = NSPredicate(format: "parentFolder.name=%@", selectedFolder!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, additionalPredicate])
        }else {
            request.predicate = folderPredicate
        }
        
        do{
            notes = try context.fetch(request)
        }catch{
            print("Error loading notes \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    
    //MARK: - Update note func
    func updateNote(with title: String, image: UIImage?, location: String?) {
        notes = []
        let newNote = Note(context: context)
        if let image = image {
            let timestamp = String(NSDate().timeIntervalSince1970)
            newNote.imageName = timestamp
            self.saveImage(timestamp, image: image)
        }
        newNote.location = location ?? ""
        newNote.title = title
        newNote.parentFolder = selectedFolder
        saveNotes()
        loadNotes()
    }
    
    //MARK: - Delete Note func
    func deleteNote(note: Note) {
        
        selectedFolder?.removeFromNotes(note)
        context.delete(note)
    }
    
    //MARK: - Save Notes
    func saveNotes() {
        do{
            try context.save()
        }catch{
            print("Error saving the notes \(error.localizedDescription)")
        }
        
    }
    
    func showSearchBar(){
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Note"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }
    
    
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

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != "moveNoteSegue" else {  return true }
        return deletingMovingOption ? false : true
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? AddNoteViewController {
            destination.delegate = self
            if let cell = sender as? UITableViewCell {
                if let index = tableView.indexPath(for: cell)?.row {
                    destination.selectedNote = notes[index]
                }
            }
        }
        
        if let destination = segue.destination as? MoveNotesViewController {
            if let index = tableView.indexPathsForSelectedRows{
                let rows = index.map{$0.row}
                destination.selectedNotes = rows.map{notes[$0]}
            }
        }
    }
    
    @IBAction func unwindToNoteTVC(_ unwindSegue: UIStoryboardSegue) {
        saveNotes()
        loadNotes()
        tableView.setEditing(false, animated: true)
    }
    
    func saveImage(_ fileName: String, image: UIImage) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality:  1.0),
          !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
}


//MARK: - search bar delegate method
extension NoteListViewController: UISearchBarDelegate{

    //MARK: - Search func
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //add predicate
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        loadNotes(predicate: predicate)
    }
    
    //text change
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadNotes()
            
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
        }
    }
}
     


