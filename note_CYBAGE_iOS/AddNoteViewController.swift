//
//  AddNoteViewController.swift
//  note_CYBAGE_iOS
//
//  Created by user186823 on 2/3/21.
//

import UIKit
import CoreLocation

class AddNoteViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelCoordinates: UILabel!
    
    
    var locationManager = CLLocationManager()

    var selectedNote: Note?{
        didSet{
           editMode = true
        }
    }
    
    var editMode: Bool = false
    
    weak var delegate: NoteListViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.noteTextView.text = selectedNote?.title
        self.labelCoordinates.text = selectedNote?.location
        if let image = self.getImage(selectedNote?.imageName ?? "") {
            self.imageView.image = image
        }
        else {
            noteTextView.becomeFirstResponder()
        }
        self.addDoneButtonOnKeyboard()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if editMode{
            delegate!.deleteNote(note: selectedNote!)
        }
        delegate!.updateNote(with : noteTextView.text, image: imageView.image, location: labelCoordinates.text ?? "")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        noteTextView.resignFirstResponder()
    }
    
    @IBAction func addPhoto(_ sender: UIBarButtonItem) {
        noteTextView.resignFirstResponder()
        let cameraPicker = UIImagePickerController()
        if(UIImagePickerController .isSourceTypeAvailable(.savedPhotosAlbum)){
            cameraPicker.sourceType = .photoLibrary
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
        else {
        }
        
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        noteTextView.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        noteTextView.resignFirstResponder()
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
        locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let val = "Latitude - \(locValue.latitude)   Longitude - \(locValue.longitude)"
        self.labelCoordinates.text = val
    }
    
    
    func getImage(_ fileName: String)-> UIImage? {
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           let fileURL = documentsDirectory.appendingPathComponent(fileName)
           if FileManager.default.fileExists(atPath: fileURL.path){
               if let data = try? Data(contentsOf: fileURL) {
                   return UIImage(data: data)
               }
           }
           return nil
       }
    
    
    /*// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    
    //Confirming The Add notes part
    //Received The Changes
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UIImage PickerControllerDelegate
extension AddNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        picker.dismiss(animated: true, completion: nil)
        let image = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage)
        self.imageView.image = image
    }

    
    func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }

}
