//
//  ViewController.swift
//  Telegram-iOS
//
//  Created by Kostya Lee on 28/08/23.
//

import UIKit

let rowHeight = UIDevice().userInterfaceIdiom == .pad ? 130.0 : 80.0

class ViewController: UIViewController {
    
    private let archivedChatsView = ArchivedChatsView()
    private let tableView: UITableView = UITableView()
    private var offsetConstraint: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        self.navigationItem.title = "Telegram Contest"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        archivedChatsView.initViews()
        self.tableView.addSubview(archivedChatsView)
        
        addOffsetObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height
        )
        archivedChatsView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: 0
        )
    }
        
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y - (-98.4)
        let offsetObject: [String : CGFloat] = ["offset" : offset]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidScrollToTop"), object: nil, userInfo: offsetObject)

        if scrollView.contentOffset.y <= -98.4 {
            let offset1 = scrollView.contentOffset.y - (-98.4)
            let offsetObject1: [String : CGFloat] = ["offset" : offset1]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidScrollToTopWithOffset"), object: nil, userInfo: offsetObject1)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if offsetConstraint < -rowHeight {
            self.tableView.contentInset.top = rowHeight
            self.archivedChatsView.didEndDragging?(scrollView)
        } else if offsetConstraint > 0 {
            self.tableView.contentInset.top = 0
        }
    }
}

extension ViewController {
    private func addOffsetObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self._move(_:)), name: NSNotification.Name(rawValue: "DidScrollToTop"), object: nil)
    }
    
    @objc func _move(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let offset = dict["offset"] as? CGFloat {
                self.offsetConstraint = offset
                self.archivedChatsView.frame.size.height = -1*offset < 0 ? 0 : -1*offset
                self.archivedChatsView.frame.origin.y = offset < 0 ? offset : 0
            }
        }
    }
}
