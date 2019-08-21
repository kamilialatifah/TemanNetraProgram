//
//  TableViewController.swift
//  TemanNetraProgram
//
//  Created by Kamilia Latifah on 21/08/19.
//  Copyright © 2019 Georgius Yoga Dewantama. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, NoteViewDelegate {
    
    var selectedIndex  = -1
    
    var arrNotes = [[String: String]] ()
    
    
    @IBAction func newNote()  {
        var newDict  = ["title"  :  "", "body" : ""]
        
        arrNotes.insert(newDict, at: 0)
        
        self.selectedIndex = 0
        
        self.tableView.reloadData()
        
        performSegue(withIdentifier: "showEditorSegue", sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func  didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the desired # of elements, In this case, 5
        
        return arrNotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //grab the "default cell/;, using the identifier we set up in the storyboard
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //set the text to a test value to make sure it's working
        cell.textLabel!.text = arrNotes[indexPath.row] ["title"]
        //return the newly-modifed cell
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.row
        
        performSegue(withIdentifier: "showEditorSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //grab the view controller we're going to transition to
        let notesEditorVC =  segue.destination as! NotesViewController
        
        //set the title of the Navigation bar to the selectedIndex'  title
        notesEditorVC.navigationItem.title =  arrNotes[self.selectedIndex] ["title"]
        
        notesEditorVC.strBodyText = arrNotes[self.selectedIndex] ["body"]
        
        notesEditorVC.delegate = self
    }
    
    func didUpdateNoteWithTitle(newTitle: String, andBody newBody: String) {
        self.arrNotes[self.selectedIndex] ["title"] = newTitle
        self.arrNotes[self.selectedIndex] ["body"] = newBody
        
        //refresh the view
        self.tableView.reloadData()
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
