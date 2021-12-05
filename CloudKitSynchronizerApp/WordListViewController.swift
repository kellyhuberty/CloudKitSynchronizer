//
//  WordListViewController.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/20/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import UIKit
import GRDB
import CloudKitSynchronizer
import UniformTypeIdentifiers

class WordListViewController: UIViewController, WordListTableCellDelegate {
    
    enum Section: String, CaseIterable, Hashable {
        case item = "item"
        case addItem = "addItem"
    }
    
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
    
    var selectedAvatarItem: Item?
    
    func refetchResults() {
        let data = try! repo.databaseQueue.read { [weak self] (db) -> [Item] in
            guard let self = self else { return [] }
            return try! Item.fetchAll(db, self.modelRequest)
        }
        
        self.data = data
    }
    
    lazy var diffableDataSource: UITableViewDiffableDataSource<Section, Item> = {
        
        let dataSource = CustomTableViewDiffableDataSource<Section, Item>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
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
        
        dataSource.delegate = self
        
        return dataSource
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
            UIKeyCommand(title: "Down",
                         image: nil,
                         action: #selector(downArrowAction(_:)),
                         input: UIKeyCommand.inputDownArrow, modifierFlags: [],
                         propertyList: nil,
                         alternates: [],
                         discoverabilityTitle: "Down",
                         attributes: [],
                         state: .on)
        
        let upArrow =
            UIKeyCommand(title: "Up",
                         image: nil,
                         action: #selector(upArrowAction(_:)),
                         input: UIKeyCommand.inputUpArrow, modifierFlags: [],
                         propertyList: nil,
                         alternates: [],
                         discoverabilityTitle: "Up",
                         attributes: [],
                         state: .on)
        
        let delete =
            UIKeyCommand(title: "Delete",
                         image: nil,
                         action: #selector(deleteAction(_:)),
                         input: "\u{8}", modifierFlags: [],
                         propertyList: nil,
                         alternates: [],
                         discoverabilityTitle: "Delete",
                         attributes: [],
                         state: .on)
        

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
        
        observer = try! regionObservation.start(in: repo.databaseQueue) { [weak self] (database) in
            DispatchQueue.main.async {
                self?.refetchResults()
            }
        }

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
        repo.refreshFromCloud {
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
    
    func itemCellTappedAvatar(_ itemCell: WordListTableCell) {
        let imgPickerVC = UIImagePickerController()
        imgPickerVC.delegate = self
        
        let utType: String
        


        if #available(iOS 14, tvOS 14, macOS 11, *) {
            utType = UTType.jpeg.identifier
        }
        else {
            utType = "UTType.jpeg.identifier"
        }

        print(utType)

        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) &&
            UIImagePickerController.availableMediaTypes(for: .photoLibrary)?.contains(utType as String) ?? false {
            imgPickerVC.sourceType = .photoLibrary
            imgPickerVC.mediaTypes.append(utType as String)
        }
        
        guard imgPickerVC.mediaTypes.count > 0 else { return }
        
        imgPickerVC.modalPresentationStyle = .popover
        imgPickerVC.popoverPresentationController?.sourceView = itemCell.avatarView
        
        selectedAvatarItem = itemCell.item
        
        self.present(imgPickerVC, animated: true) {
            
        }
        
    }
}

extension WordListViewController: CustomTableViewDiffableDataSourceDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = Section.allCases[indexPath.section]
        
        switch section {
        case .item:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let section = Section.allCases[indexPath.section]
        
        switch section {
        case .item:
            if let item = diffableDataSource.itemIdentifier(for: indexPath) {
                removeItem(item)
            }
        default:
            break
        }
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

extension WordListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        guard var item = selectedAvatarItem else {
            return
        }
        selectedAvatarItem = nil
        item.imageAsset.image = image
        addEditItem(item)
        picker.dismiss(animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        selectedAvatarItem = nil
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

class CustomTableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>:
    UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    where SectionIdentifierType : Hashable, ItemIdentifierType : Hashable {
    
    weak var delegate: CustomTableViewDiffableDataSourceDelegate?
    
    override func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if let delegate = delegate,
           delegate.responds(to: #selector(CustomTableViewDiffableDataSourceDelegate.tableView(_:commit:forRowAt:))) {
            delegate.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
        }
        else {
            super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let delegate = delegate,
           delegate.responds(to: #selector(CustomTableViewDiffableDataSourceDelegate.tableView(_:canEditRowAt:))) {
            return delegate.tableView?(tableView, canEditRowAt: indexPath) ??
                super.tableView(tableView, canEditRowAt: indexPath)
        }
        else {
            return super.tableView(tableView, canEditRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let delegate = delegate,
           delegate.responds(to: #selector(CustomTableViewDiffableDataSourceDelegate.tableView(_:canMoveRowAt:))) {
            return delegate.tableView?(tableView, canMoveRowAt: indexPath) ??
                super.tableView(tableView, canMoveRowAt: indexPath)
        }
        else {
            return super.tableView(tableView, canMoveRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        if let delegate = delegate,
           delegate.responds(to: #selector(CustomTableViewDiffableDataSourceDelegate.tableView(_:moveRowAt:to:))) {
            return delegate.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath) ??
                self.tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        }
        else {
            return super.tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        }
        
    }
}

@objc protocol CustomTableViewDiffableDataSourceDelegate: NSObjectProtocol {
    @objc optional func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath)
    @objc optional func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    
    @objc optional func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    @objc optional func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath)
}
