//
//  CommentViewController.swift
//  FireStoreBasic
//
//  Created by 近藤米功 on 2022/06/19.
//

import UIKit
import Firebase
import FirebaseFirestore

class CommentViewController: UIViewController {

    var idString: String = ""
    var kaitouString: String = ""

    @IBOutlet private var kaitouLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var sendButton: UIButton!


    var userName: String = ""

    let db = Firestore.firestore()

    var dataSets: [Comment] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("idString",idString)
        tableView.delegate = self
        tableView.dataSource = self
        kaitouLabel.text = kaitouString
        if UserDefaults.standard.object(forKey: "nameKey") != nil{
            userName = UserDefaults.standard.object(forKey: "nameKey") as! String
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        loadData()
    }

    @IBAction func didTapSendButton(_ sender: Any) {
        if textField.text?.isEmpty == true{
            return
        }
        
        db.collection("Answers").document(idString).collection("comments").document().setData(["userName":userName as Any,"comment":textField.text! as Any,"postDate":Date().timeIntervalSince1970])
        textField.text = ""
    }

    private func loadData(){
        db.collection("Answers").document(idString).collection("comments").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            self.dataSets = []
            if error != nil{
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let userName = data["userName"] as? String,let comment = data["comment"] as? String,let postDate = data["postDate"] as? Double{
                        let comment = Comment(userName: userName, comment: comment, postDate: postDate)
                        self.dataSets.append(comment)
                    }
                }
                self.dataSets.reverse()
                self.tableView.reloadData()
            }
        }
    }
}
extension CommentViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        tableView.rowHeight = 200
        let commentLabel = cell.contentView.viewWithTag(1) as! UILabel
        commentLabel.numberOfLines = 0
        commentLabel.text = "\(self.dataSets[indexPath.row].userName)くん\n\(self.dataSets[indexPath.row].comment)"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        // tableViewの高さを可変にする
        return UITableView.automaticDimension
    }


}
