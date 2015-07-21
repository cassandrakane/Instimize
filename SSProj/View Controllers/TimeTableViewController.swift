//
//  TimeTableViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/20/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import RealmSwift

class TimeTableViewController: UITableViewController {
    
    //@IBOutlet weak var searchBar: UISearchBar!
    
    enum State {
        case DefaultMode
        //case SearchMode
    }
    
    var info = Info.sharedInstance
    
    var times: [Time] = []
    
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
        times = info.times
    }
    
    override func didReceiveMemoryWarning() {
        //sent to the view controller when the app receives a memory warning
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



extension TimeTableViewController: UITableViewDataSource {
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //asks the data source for a cell to insert in a particular location of the table view
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell", forIndexPath: indexPath) as! TimeTableViewCell //1
        
        let row = indexPath.row
        let time = times[row] as Time
        cell.time = time
        
        
        return cell
    }
    
override     
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //tells the data source to return the number of rows in a given section of a table view
        return Int(times.count ?? 0)
    }
    
}

extension TimeTableViewController: UITableViewDelegate {
   
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

extension TimeTableViewController: UISearchBarDelegate {
    
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
