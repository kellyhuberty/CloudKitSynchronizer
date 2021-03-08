//
//  WordListViewController.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/20/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import UIKit
import GRDB

//class FetchedRecordsController {
//
//    init(_ queue: DatabaseQueue, request:SQLRequest){
//
//
//
//    }
//
//
//
//
//}

class WordListViewController: UIViewController, WordListTableCellDelegate {
    
//    enum CellModel: CaseIterable, Hashable {
//        static var allCases: Self.AllCases { [.item, .allCases] }
//        case item(Item)
//        case addItem
//    }
    
    enum Section: String, CaseIterable, Hashable {
        case item = "item"
        case addItem = "addItem"
    }
    

    
    
    
    
//    lazy var resultsController:FetchedRecordsController<Item> = {
//
//        let request = SQLRequest<Item>("select * from Item order by `text`")
//        let resultsController = try! FetchedRecordsController<Item>(Repo.shared.databaseQueue, request: request)
//
//        resultsController.trackChanges(willChange: { (item) in
//
//        }, onChange: { (controller, item, change) in
//
//        }, didChange: { [weak self] (controller) in
//            self?.tableView.reloadData()
//        })
//
//        try! resultsController.performFetch()
//        return resultsController
//    }()
    
    
    let repo: Repo
    
    let modelRequest = SQLRequest<Item>("select * from Item order by `text`")
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var observer: TransactionObserver?
    
    var data: [Item] = [] {
        didSet {
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            //var snapshot = diffableDataSource.snapshot()
            snapshot.appendSections([.item, .addItem])
            snapshot.appendItems(data, toSection: .item)
            snapshot.appendItems([Item()], toSection: .addItem)

            self.diffableDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }
    
    func refetchResults() {
        let data = repo.databaseQueue.read { [weak self] (db) -> [Item] in
            guard let self = self else { return [] }
            return try! Item.fetchAll(db, self.modelRequest)
        }
        
        self.data = data
    }
    
    lazy var diffableDataSource: UITableViewDiffableDataSource<Section, Item> = {
        
        return UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: Section.item.rawValue, for: indexPath) as! WordListTableCell

            let section = Section.allCases[indexPath.section]

            switch section {
            case .item:
                let record = item
                cell.textView.text = record.text
                cell.item = record
            case .addItem:
                cell.textView.text = nil
                cell.textView.placeholder = NSLocalizedString("Add Item", comment: "Add Item")
                cell.item = nil
            }
            cell.textView.inputAccessoryView = self.editingToolbar
            cell.delegate = self
            
            return cell
        }
    }()
    
//    lazy var dataSource: FetchedRecordsDataSource<Item> = {
//
//        let request = SQLRequest<Item>("select * from Item order by `text`")
//
//        let dataSource = FetchedRecordsDataSource<Item>(database: repo.databaseQueue,
//                                                    request: request,
//                                                    tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
//
//
//        }
//
//
//
//
//
//
//
////        let dataSource = FetchedRecordsDataSource<Item>(
////
////        resultsController.trackChanges(willChange: { (item) in
////
////        }, onChange: { (controller, item, change) in
////
////        }, didChange: { [weak self] (controller) in
////            self?.tableView.reloadData()
////        })
//
////        try! resultsController.performFetch()
////        return resultsController
//        return dataSource
//    }()
    
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
    
    var keyController: KeyController!
    
    @objc func endEditingOnView(){
        self.view.endEditing(true)
    }
    
    required init(repo: Repo) {
        self.repo = repo
        super.init(nibName: nil, bundle: nil)
        keyController = KeyController(self)
        keyController.addFirstResponderCommands()
    }
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        keyController = KeyController(self)
//        keyController.addFirstResponderCommands()
//    }
//
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        keyController.isFirstResponder = true
        return true
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        keyController.isFirstResponder = false
        return true
    }
    
//    override var keyCommands: [UIKeyCommand]? {
//        return [
//            UIKeyCommand(input: UIKeyCommand.inputDownArrow,
//                         modifierFlags: [],
//                         action: #selector(downArrowAction(_:)),
//                         discoverabilityTitle: "Down"),
//            UIKeyCommand(input: UIKeyCommand.inputUpArrow,
//                         modifierFlags: [],
//                         action: #selector(upArrowAction(_:)),
//                         discoverabilityTitle: "Up"),
//            UIKeyCommand(input: "\u{8}",
//                         modifierFlags: [],
//                         action: #selector(deleteAction(_:)),
//                         discoverabilityTitle: "Delete")
//        ]
//    }
    
    class KeyController {
                
        weak var responder: UIViewController?
        
        var firstResponderKeyCommands: [UIKeyCommand] = []
        
        var isFirstResponder: Bool = false {
            didSet{
//                if isFirstResponder {
//                    addFirstResponderCommands()
//                }
//                else {
//                    removeFirstResponderCommands()
//                } 
            }
        }
        
        init(_ responder: UIViewController) {
            self.responder = responder
            responder.addKeyCommand(downArrow)
            responder.addKeyCommand(upArrow)
            firstResponderKeyCommands.append(delete)
            firstResponderKeyCommands.append(selectAll)
            firstResponderKeyCommands.append(reload)
        }
    
        let downArrow =
            UIKeyCommand(input: UIKeyCommand.inputDownArrow,
                         modifierFlags: [],
                         action: #selector(downArrowAction(_:)),
                         discoverabilityTitle: "Down")
        
        let upArrow =
            UIKeyCommand(input: UIKeyCommand.inputUpArrow,
                         modifierFlags: [],
                         action: #selector(upArrowAction(_:)),
                         discoverabilityTitle: "Up")
        
        let delete =
            UIKeyCommand(input: "\u{8}",
                         modifierFlags: [],
                         action: #selector(deleteAction(_:)),
                         discoverabilityTitle: "Delete")
        
        let selectAll =
            UIKeyCommand(title: "Select All",
                         image: nil,
                         action: #selector(selectAllAction(_:)),
                         input: "a", modifierFlags: [.command],
                         propertyList: nil,
                         alternates: [],
                         discoverabilityTitle: nil,
                         attributes: [],
                         state: .on)
        
        let reload =
            UIKeyCommand(title: "Reload",
                         image: nil,
                         action: #selector(refreshAction(_:)),
                         input: "r", modifierFlags: [.command],
                         propertyList: nil,
                         alternates: [],
                         discoverabilityTitle: nil,
                         attributes: [],
                         state: .on)
        
        func addFirstResponderCommands() {
            for command in firstResponderKeyCommands {
                if !(responder?.keyCommands?.contains(command) ?? false) {
                    responder?.addKeyCommand(command)
                }
            }
        }
        
        func removeFirstResponderCommands() {
            for command in firstResponderKeyCommands {
                if (responder?.keyCommands?.contains(command) ?? false) {
                    responder?.removeKeyCommand(command)
                }
            }
        }
    }
    
    lazy var regionObservation = {
        DatabaseRegionObservation(tracking: modelRequest)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let modelRequest = SQLRequest<Item>("select * from Item order by `text`")

//        let regionObservation = DatabaseRegionObservation(tracking: modelRequest)
        observer = try! regionObservation.start(in: repo.databaseQueue) { [weak self] (database) in
            DispatchQueue.main.async {
                self?.refetchResults()
            }
        }

        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.register(WordListTableCell.self, forCellReuseIdentifier: Section.item.rawValue)
        tableView.register(WordListTableCell.self, forCellReuseIdentifier: Section.addItem.rawValue)
        data = []

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: tableView.topAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
        ])


        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = true

        // Uncomment the following line to preserve selection between presentations
//        tableView.clearsSelectionOnViewWillAppear = false
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.refetchResults()
        super.viewDidAppear(animated)
    }

    @objc func refreshAction(_ sender: Any) {
        repo.cloudSynchronizer?.refreshFromCloud {
            DispatchQueue.main.async {
                (sender as? UIRefreshControl)?.endRefreshing()
            }
        }
    }
    
    @objc func deleteAction(_ sender: Any) {
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            let record = diffableDataSource.itemIdentifier(for: indexPath)
            guard let uwrecord = record else{
                continue
            }
            removeItem(uwrecord)
        }
    }
    
    @objc func upArrowAction(_ sender: Any) {
        guard let indexPath = tableView.indexPathsForSelectedRows?.first else {
            return
        }
        tableView.deselectAll()
        guard let newIndexPath = tableView.indexPath(before: indexPath) else {
            return
        }
        tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .top)
    }
    
    @objc func downArrowAction(_ sender: Any) {
        guard let indexPath = tableView.indexPathsForSelectedRows?.last else {
            return
        }
        tableView.deselectAll()
        guard let newIndexPath = tableView.indexPath(after: indexPath) else {
            return
        }
        tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .bottom)
    }
    
    @objc func selectAllAction(_ sender: Any) {
        tableView.selectAll()
    }
    
    // MARK: - Table view data source
/*
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
*/
    
    func editItem(_ item: Item) {
        try! repo.databaseQueue.write { (db) -> Void in
            try! item.save(db)
        }
    }
    
    func addEditItem(_ item: Item) {
        try! repo.databaseQueue.write { (db) -> Void in
            try! item.save(db)
        }
    }
    
    func removeItem(_ item: Item) {
        try! repo.databaseQueue.write { (db) -> Void in
            try! item.delete(db)
        }
    }
    
    func itemCellDidBeginEditing(_ itemCell: WordListTableCell) {
        

        keyController.removeFirstResponderCommands()
        
        tableView.deselectAll()
        
    }
    
    func itemCellDidChange(_ itemCell:WordListTableCell){
        
        var item:Item

        if let cellItem = itemCell.item {
            item = cellItem
        }else{
            item = Item()
            item.text = itemCell.textView.text
        }

        addEditItem(item)
    }
    
    func itemCellDidEndEditing(_ itemCell: WordListTableCell) {
        
        keyController.addFirstResponderCommands()
        
        var item:Item
        
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

extension WordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let section = Section.allCases[indexPath.section]
        
//        switch section {
//        case .item:
//            let record = resultsController.record(at: indexPath)
//            removeItem(record)
//        default:
//            break
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(false)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let section = Section.allCases[indexPath.section]
        if section == .item {
            return indexPath
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
}

extension UITableView {
    func deselectAll() {
        for indexPath in self.indexPathsForSelectedRows ?? [] {
            self.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func selectAll() {
        var seedPath:IndexPath = IndexPath(row: -1, section: 0)
        
        while let nextPath = indexPath(after: seedPath) {
            if let indexPath = self.delegate?.tableView?(self, willSelectRowAt: nextPath) {
                self.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
            seedPath = nextPath
        }
    }
}


extension UITableView {
    
    func indexPath(before: IndexPath) -> IndexPath? {
        return nextSelectablePathExists(before, rowModifier: { (row) -> Int in
            return row - 1
        }) { (section) -> (row:Int, section:Int) in
            return (
                row: 0,
                section: section - 1
            )
        }
    }
    
    func indexPath(after: IndexPath) -> IndexPath? {
        return nextSelectablePathExists(after, rowModifier: { (row) -> Int in
            return row + 1
        }) { (section) -> (row:Int, section:Int) in
            return (
                row: 0,
                section: section + 1
            )
        }
    }
    
    private func nextSelectablePathExists(_ indexPath: IndexPath, rowModifier:(Int)->Int, sectionModifier:(Int)->(row:Int, section:Int) ) -> IndexPath? {
        
        let sectionCount = self.numberOfSections
        var rowCount = numberOfRows(inSection: indexPath.section)

        var newSection = indexPath.section
        var newRow = rowModifier(indexPath.row)
            
        while newRow < 0 || newRow >= rowCount {
            let newRowAndSection = sectionModifier(newSection)
            newRow = newRowAndSection.row
            newSection = newRowAndSection.section
            if newSection < 0 || newSection >= sectionCount {
                return nil
            }
            rowCount = numberOfRows(inSection: newSection)
        }

        return IndexPath(row: newRow, section: newSection)
        
    }
    
    func indexPathSectionValid(_ indexPath:IndexPath) -> Bool {
        let sectionCount = numberOfSections
        return indexPath.row < 0 || indexPath.row >= sectionCount
    }
    
    func indexPathRowValid(_ indexPath:IndexPath) -> Bool {
        let rowCount = numberOfRows(inSection: indexPath.section)
        return indexPath.row < 0 || indexPath.row >= rowCount
    }
    
}


/*
typealias SectionIdentifierType = Int

class FetchedRecordsObserver<ModelType, ViewModelType>: UITableViewDiffableDataSource<SectionIdentifierType, ModelType> where ModelType: Hashable, ModelType: FetchableRecord {
    
//    typealias SectionIdentifierType = Int
        
    let diffableDataSource: UITableViewDiffableDataSource<SectionIdentifierType, ModelType>
        
    let modelRequest: SQLRequest<ModelType>
    
    let databaseQueue: DatabaseQueue
    
    let transactionObserver: TransactionObserver

    weak var delegate: UITableViewDelegate?

    var data: [ModelType] = [] {
        didSet {
            
            var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ModelType>()
            
            snapshot.appendSections([0])
            snapshot.appendItems(data, toSection: 0)
            
            diffableDataSource.apply(snapshot)
        }
    }
    
    init(database databaseQueue: DatabaseQueue,
         request modelRequest: SQLRequest<ModelType>,
         tableView: UITableView) {

        self.modelRequest = modelRequest
        let regionObserver = DatabaseRegionObservation(tracking: modelRequest)
        self.databaseQueue = databaseQueue
        transactionObserver = try! regionObserver.start(in: databaseQueue) { [weak self] (database) in
            DispatchQueue.main.async {
                self?.refetchResults()
            }
        }
        
        super.init()
    }
    
    func refetchResults() {
        data = self.databaseQueue.read { [weak self] (db) -> [ModelType] in
            guard let self = self else { return [] }
            return try! ModelType.fetchAll(db, self.modelRequest)
        }
    }

}
*/
