//
//  WordListViewController.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/20/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import UIKit
import GRDB


class WordListViewController: UITableViewController, WordListTableCellDelegate {
    
    enum Section: String, CaseIterable{
        case item = "WordListViewController.Section.item"
        case addItem = "WordListViewController.Section.addItem"
    }
    
    lazy var resultsController:FetchedRecordsController<Item> = {
        
        let request = SQLRequest<Item>("select * from Item order by `text`")
        let resultsController = try! FetchedRecordsController<Item>(Repo.shared.databaseQueue, request: request)
        
        resultsController.trackChanges(willChange: { (item) in
            
        }, onChange: { (controller, item, change) in
            
        }, didChange: { [weak self] (controller) in
            self?.tableView.reloadData()
        })
        
        try! resultsController.performFetch()
        return resultsController
    }()
    
    lazy var editingToolbar:UIToolbar? = {
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let barItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditingOnView))
                ]
        
        toolbar.items = barItems
       // toolbar.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return toolbar
    }()
    
    @objc func endEditingOnView(){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(WordListTableCell.self, forCellReuseIdentifier: Section.item.rawValue)
        tableView.register(WordListTableCell.self, forCellReuseIdentifier: Section.addItem.rawValue)
        
        let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("PullToRefresh", comment: "Pull to refresh")
        refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.addTarget(self,
                                 action: #selector(refreshAction(_:)),
                                 for: .valueChanged)
        tableView.refreshControl = refreshControl
                
    }

    @objc func refreshAction(_ sender: Any) {
        
        Repo.shared.cloudSynchronizer?.refreshFromCloud {
            DispatchQueue.main.async {
                (sender as? UIRefreshControl)?.endRefreshing()
            }
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = Section.allCases[section]
        
        if section == .item {
            
            return resultsController.sections.first?.numberOfRecords ?? 0
            
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Section.item.rawValue, for: indexPath) as! WordListTableCell

        let section = Section.allCases[indexPath.section]

        switch section {
        case .item:
            let record = resultsController.record(at: indexPath)
            cell.textView.text = record.text
            cell.item = record
        case .addItem:
            cell.textView.text = nil
            cell.textView.placeholder = NSLocalizedString("Add Item", comment: "Add Item")
            cell.item = nil
        }
        cell.textView.inputAccessoryView = editingToolbar
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let section = Section.allCases[indexPath.section]
        
        switch section {
        case .item:
            let record = resultsController.record(at: indexPath)
            removeItem(record)
        default:
            break
        }
    }
    
    func editItem(_ item: Item) {
        
        item.save { (status) in
            
        }
        
        
    }
    
    func addEditItem(_ item: Item) {

        item.save { (status) in
            
        }
        
        
    }
    
    func removeItem(_ item: Item) {
        
        item.delete { (status) in

        }
        
        
    }
    
    func itemCellDidBeginEditing(_ itemCell: WordListTableCell) {
        
//        let item:Item
//
//        if let cellItem = itemCell.item {
//            item = cellItem
//        }else{
//            item = Item()
//            item.text = itemCell.textView.text
//        }
//
//        addEditItem(item)
    }
    
    func itemCellDidChange(_ itemCell:WordListTableCell){
        
//        let item:Item
//
//        if let cellItem = itemCell.item {
//            item = cellItem
//        }else{
//            item = Item()
//            item.text = itemCell.textView.text
//        }
//
//        addEditItem(item)
    }
    
    func itemCellDidEndEditing(_ itemCell: WordListTableCell) {
        
        let item:Item
        
        if let cellItem = itemCell.item {
            item = cellItem
        }else{
            item = Item()
        }

        item.text = itemCell.textView.text

        addEditItem(item)
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
