//
//  TableCell.swift
//  Telegram-iOS
//
//  Created by Kostya Lee on 28/08/23.
//

import UIKit

class TableCell: UITableViewCell {
    
    private let _imageView = UIView()
    private let titleView = UIView()
    private let subtitleView = UIView()
    private let timeView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        [_imageView,
        titleView,
        subtitleView,
        timeView].forEach { view in
            view.backgroundColor = .gray
            self.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let padding = 16.0
        NSLayoutConstraint.activate([
            _imageView.widthAnchor.constraint(equalToConstant: 50),
            _imageView.heightAnchor.constraint(equalToConstant: 50),
            _imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: padding),
            _imageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            titleView.widthAnchor.constraint(equalToConstant: 80),
            titleView.heightAnchor.constraint(equalToConstant: 15),
            titleView.leftAnchor.constraint(equalTo: _imageView.rightAnchor, constant: padding),
            titleView.topAnchor.constraint(equalTo: _imageView.topAnchor, constant: 5),
            
            subtitleView.widthAnchor.constraint(equalToConstant: 120),
            subtitleView.heightAnchor.constraint(equalToConstant: 15),
            subtitleView.leftAnchor.constraint(equalTo: _imageView.rightAnchor, constant: padding),
            subtitleView.bottomAnchor.constraint(equalTo: _imageView.bottomAnchor, constant: -5),
            
            timeView.widthAnchor.constraint(equalToConstant: 60),
            timeView.heightAnchor.constraint(equalToConstant: 15),
            timeView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -padding),
            timeView.topAnchor.constraint(equalTo: _imageView.topAnchor),
        ])
        
        _imageView.layer.cornerRadius = 25
        titleView.layer.cornerRadius = 3
        subtitleView.layer.cornerRadius = 3
        timeView.layer.cornerRadius = 3
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
}
