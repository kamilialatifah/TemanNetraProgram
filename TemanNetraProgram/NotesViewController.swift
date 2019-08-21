//
//  NotesViewController.swift
//  TemanNetraProgram
//
//  Created by Kamilia Latifah on 21/08/19.
//  Copyright © 2019 Georgius Yoga Dewantama. All rights reserved.
//

import UIKit

//save the selected value
protocol NoteViewDelegate {
    func didUpdateNoteWithTitle(newTitle : String, andBody newBody: String)
}

class NotesViewController: UIViewController, UITextViewDelegate {
    
    var delegate : NoteViewDelegate?
    
    @IBOutlet weak var isiNotes: UITextView!
    
    var strBodyText : String!
    
    @IBOutlet weak var btnDoneEditing:  UIBarButtonItem!
    
    //done button
    @IBAction func doneEditingBody() {
        
        //hides keyboard
        self.isiNotes.resignFirstResponder()
        
        //makes  the button invisible
        self.btnDoneEditing.tintColor  = UIColor.clear
        
        if self.delegate != nil {
            
            self.delegate!.didUpdateNoteWithTitle(newTitle: self.navigationItem.title!, andBody: self.isiNotes.text)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isiNotes.text = self.strBodyText
        self.isiNotes.becomeFirstResponder()
        self.isiNotes.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.delegate != nil {
            self.delegate!.didUpdateNoteWithTitle(newTitle: self.navigationItem.title!, andBody: self.isiNotes.text)
        }
    }
    
    func textViewDidBeginEditing(_ textView:  UITextView) {
        
        self.btnDoneEditing.tintColor = UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 1)
    }
    
    func didUpdateNoteWithTitle(newTitle: String, andBody newBody: String) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //separate the body into multiple sections
        
        let components = self.isiNotes.text.components(separatedBy: "\n")
        
        //reset the title to blank (in case there are no components with valid text)
        
        self.navigationItem.title = ""
        
        //loop through each item in the components array  (each item is auto-detected as a string)
        for item in components  {
            if item.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                
                self.navigationItem.title = item
                break
            }
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
