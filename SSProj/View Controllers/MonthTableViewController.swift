//
//  MonthTableViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/20/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import RealmSwift

class MonthTableViewController: UITableViewController {
    
    //@IBOutlet weak var searchBar: UISearchBar!
    
    enum State {
        case DefaultMode
        //case SearchMode
    }
    
    var info = Info.sharedInstance
    
    /*
    var state: State = .DefaultMode {
    didSet {
    // update notes and search bar whenever State changes
    switch (state) {
    case .DefaultMode:
    let realm = Realm()
    months = realm.objects(month).sorted("modificationDate", ascending: false) //1
    //self.navigationController!.setNavigationBarHidden(false, animated: true) //2
    //searchBar.resignFirstResponder() // 3
    //searchBar.text = ""
    //searchBar.showsCancelButton = false
    /*
    case .SearchMode:
    let searchText = searchBar?.text ?? ""
    searchBar.setShowsCancelButton(true, animated: true) //4
    notes = searchNotes(searchText) //5
    self.navigationController!.setNavigationBarHidden(true, animated: true) //6
    }
    */
    }
    }
    */
    
    var months: [Month] = []
    /*
    {
    didSet {
    // Whenever notes update, update the table view
    tableView?.reloadData()
    }
    }
    */
    //var selectedNote: Note?
    
    override func viewDidLoad() {
        //called after the controller's view is loaded into memory
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //searchBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        //notifies the view controller that its view is about to be added to a view hierarchy
        super.viewWillAppear(animated)
        //let realm = Realm()
        months = info.months
        //state = .DefaultMode
    }
    
    override func didReceiveMemoryWarning() {
        //sent to the view controller when the app receives a memory warning
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
    if let identifier = segue.identifier {
    let realm = Realm()
    switch identifier {
    case "Save":
    //allows note to save
    let source = segue.sourceViewController as! NewNoteViewController //1
    
    realm.write() {
    realm.add(source.newNote!)
    }
    case "Delete":
    //deletes note
    realm.write() {
    realm.delete(self.selectedNote!)
    }
    
    let source = segue.sourceViewController as! NoteDisplayViewController
    source.note = nil
    
    default:
    println()
    //println("No one loves \(identifier)")
    }
    
    notes = realm.objects(Note).sorted("modificationDate", ascending: false) //2
    }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "ShowExistingNote") {
    //opens a pre-existing note
    let noteViewController = segue.destinationViewController as! NoteDisplayViewController
    noteViewController.note = selectedNote
    }
    }
    
    func searchNotes(searchString: String) -> Results<Note> {
    let realm = Realm()
    let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@ OR content CONTAINS[c] %@", searchString, searchString)
    return realm.objects(Note).filter(searchPredicate)
    }
    */
    
}



extension MonthTableViewController: UITableViewDataSource {
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //asks the data source for a cell to insert in a particular location of the table view
        let cell = tableView.dequeueReusableCellWithIdentifier("MonthCell", forIndexPath: indexPath) as! MonthTableViewCell //1
        
        let row = indexPath.row
        let month = months[row] as Month
        cell.month = month
        
        
        return cell
    }
    
    override
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //tells the data source to return the number of rows in a given section of a table view
        return Int(months.count ?? 0)
    }
    
}

extension MonthTableViewController: UITableViewDelegate {
    
    /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //tells the delegate that the specified row is now selected
    selectedNote = notes[indexPath.row]      //1
    self.performSegueWithIdentifier("ShowExistingNote", sender: self)     //2
    }
    
    // 3
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    //asks the data source to verify that the given row is editable (always true)
    return true
    }
    
    // 4
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    //asks the data source to commit the insertion or deletion of a specified row in the receiver
    if (editingStyle == .Delete) {
    let note = notes[indexPath.row] as Object
    
    let realm = Realm()
    
    realm.write() {
    realm.delete(note)
    }
    
    notes = realm.objects(Note).sorted("modificationDate", ascending: false)
    }
    }
    */
}

extension MonthTableViewController: UISearchBarDelegate {
    
    /*
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    notes = searchNotes(searchText)
    }
    */
}
