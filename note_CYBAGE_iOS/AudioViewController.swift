//
//  AudioViewController.swift
//  note_CYBAGE_iOS
//
//  Created by user187410 on 2/4/21.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource  {

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var numberOfRecords:Int = 0
    var audioPlayer: AVAudioPlayer!
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    
    @IBOutlet weak var buttonLbl: UIButton!
    
    @IBAction func record(_ sender: UIButton) {
        
        //check if we have an active recorder
        if audioRecorder == nil{
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 1200, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start Audio Recording
            do{
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                buttonLbl.setTitle("Stop Recording", for: .normal)
            }catch{
                displayAlert(title: "Ooooops! ", message: "Recording Faild")
            }
        }
        else{
            //Stop Recording
            audioRecorder.stop()
            audioRecorder = nil
            
            UserDefaults.standard.setValue(numberOfRecords, forKey: "myNumber")
            myTableView.reloadData()
            
            buttonLbl.setTitle("Start Recording", for: .normal)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting up Seesion
        recordingSession = AVAudioSession.sharedInstance()
        
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int{
            numberOfRecords = number
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission{
                print("ACCEPTED")
            }
        }
        
    }
    
    
    //Function that gets path directory
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }

    //Function that display an alert
    func displayAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        }catch{
            
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
