//
//  WordListTableCell.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/20/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import UIKit

class WordListTableCell: UITableViewCell {

    static let defaultAvatar: UIImage = {
        UIImage(systemName:"person.crop.circle.fill")!
    }()
    
    let textView: UITextField = {
        let view = UITextField()
        view.adjustsFontForContentSizeCategory = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var avatarViewGestureRecognizer: UIGestureRecognizer? = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapAction(_:)))
        recognizer.numberOfTapsRequired = 1
        return recognizer
    }()
    
    let avatarView: UIImageView = {
        let view = UIImageView()
        view.image = WordListTableCell.defaultAvatar
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    weak var delegate:WordListTableCellDelegate? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }

    var item: Item? {
        willSet {
            item?.imageAsset.changed = nil
        }
        didSet{
            if var newItem = item {
                newItem.imageAsset.changed = { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self, self.item == newItem else { return }
                        self.avatarView.image = newItem.imageAsset.uiimage ?? WordListTableCell.defaultAvatar
                    }
                }
            }
            else {
                avatarView.image = WordListTableCell.defaultAvatar
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLayout()
    }
    
    func configureLayout(){
        
        contentView.addSubview(textView)
        contentView.addSubview(avatarView)

        NSLayoutConstraint.activate([
            
            avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 44).withPriority(.required),

            avatarView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            avatarView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            avatarView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            
            
            
            textView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
            textView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: 55),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])

        textView.addTarget(self, action: #selector(textDidChange), for: .valueChanged)
        textView.addTarget(self, action: #selector(textDidEndEditing), for: .editingDidEnd)
        textView.addTarget(self, action: #selector(textDidBeginEditing), for: .editingDidBegin)

        avatarView.addGestureRecognizer(avatarViewGestureRecognizer!)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = avatarView.frame.height / 2
        avatarView.layer.cornerRadius = radius
    }
    
    @objc func avatarTapAction(_ sender: Any) {
        delegate?.itemCellTappedAvatar(self)
    }
    
}

@objc protocol WordListTableCellDelegate{
    
    func itemCellDidChange(_ itemCell:WordListTableCell)
    func itemCellDidBeginEditing(_ itemCell:WordListTableCell)
    func itemCellDidEndEditing(_ itemCell:WordListTableCell)
    
    func itemCellTappedAvatar(_ itemCell:WordListTableCell)
}

extension NSLayoutConstraint{
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
