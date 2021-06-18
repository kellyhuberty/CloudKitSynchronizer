//
//  WordListTableCell.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/20/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import UIKit

class WordListTableCell: UITableViewCell {

    let textView:UITextField = {
        let view = UITextField()
        view.adjustsFontForContentSizeCategory = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    weak var delegate:WordListTableCellDelegate? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }

    var item:Item?{
        didSet{
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLayout()
    }
    
    func configureLayout(){
        
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: 55),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])

        textView.addTarget(self, action: #selector(textDidChange), for: .valueChanged)
        textView.addTarget(self, action: #selector(textDidEndEditing), for: .editingDidEnd)
        textView.addTarget(self, action: #selector(textDidBeginEditing), for: .editingDidBegin)

    }
    
    @objc func textDidBeginEditing(){
        
        delegate?.itemCellDidBeginEditing(self)
        
    }
    
    @objc func textDidChange(){
        
        delegate?.itemCellDidChange(self)
        
    }
    
    @objc func textDidEndEditing(){
        
        delegate?.itemCellDidEndEditing(self)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return true
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return true
    }

}

@objc protocol WordListTableCellDelegate{
    
    func itemCellDidChange(_ itemCell:WordListTableCell)
    func itemCellDidBeginEditing(_ itemCell:WordListTableCell)
    func itemCellDidEndEditing(_ itemCell:WordListTableCell)
    
}
