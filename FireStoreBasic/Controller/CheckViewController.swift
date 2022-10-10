//
//  CheckViewController.swift
//  FireStoreBasic
//
//  Created by 近藤米功 on 2022/06/19.
//

import UIKit
import Firebase
import FirebaseFirestore


class CheckViewController: UIViewController {

    @IBOutlet private var odaiLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    let db = Firestore.firestore()
    var dataSets: [Answers] = []
    var idString: String = ""
    // お題参照DB
    let odaiDB = Firestore.firestore().collection("Odai").document("aRgYqZoremhOVUMDPW3E")

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CustumCell", bundle: nil), forCellReuseIdentifier: "Cell")
        if UserDefaults.standard.object(forKey: "documentID") != nil{
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        }
        setOdaiLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        loadData()
    }

    private func loadData(){
        // Answersのdocument(全て）をひっぱる、postDateの古い順に

        // dataSetsに入れる
        db.collection("Answers").order(by: "postDate").addSnapshotListener { snapShot, error in
            self.dataSets = []
            if error != nil{
                return
            }
            // .documentsと指定することでdocument全体が入る
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let answer = data["answer"] as? String,let userName = data["userName"] as? String,let likeCount = data["like"] as? Int,let likeFlagDic = data["likeFlagDic"] as? Dictionary<String,Bool>{
                        if likeFlagDic["\(doc.documentID)"] != nil{
                            let answerModel = Answers(answers: answer, userName: userName, docID: doc.documentID, likeCount: likeCount, likeFlagDic: likeFlagDic)
                            self.dataSets.append(answerModel)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
    }
    }
    private func setOdaiLabel(){
        odaiDB.getDocument { snapShot, error in
            if error != nil{
                return
            }
            let data = snapShot?.data()
            guard let data = data else{
                return
            }
            self.odaiLabel.text = data["odaiText"] as? String
        }
    }
}
extension CheckViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustumCell
        tableView.rowHeight = 200
        cell.answerLabel.numberOfLines = 0
        cell.answerLabel.text = "\(self.dataSets[indexPath.row].userName)くんの回答\n\(self.dataSets[indexPath.row].answers)"
        cell.likeButton.tag = indexPath.row
        cell.countLabel.text = String(self.dataSets[indexPath.row].likeCount) + "いいね"
        cell.likeButton.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)

        // いいねが押されていたらlikeButtonの色を出す。
        if (self.dataSets[indexPath.row].likeFlagDic[idString] != nil) == true{


            let flag = self.dataSets[indexPath.row].likeFlagDic[idString]

            if flag! as! Bool == true{
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }else{
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
        return cell
    }

    @objc func like(_ sender:UIButton){
        print(sender.debugDescription) // likeButtonの情報が出力されるはず
        var count: Int = 0
        // ここでいうtagはlikeButtonのtagの同じ
        let flag = self.dataSets[sender.tag].likeFlagDic[idString]
        // flagがない時 = IDがない時
        if flag == nil{
            count = self.dataSets[sender.tag].likeCount + 1
            // 今あるいいねと合体（merge)する
            db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
        }else{
            if flag! as! Bool == true{
                count = self.dataSets[sender.tag].likeCount - 1
                // 今あるいいねと合体（merge)する
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString:false]], merge: true)
            }else if flag! as! Bool == false{
                count = self.dataSets[sender.tag].likeCount + 1
                // 今あるいいねと合体（merge)する
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
            }
        }
        // count情報を送信
        db.collection("Answers").document(dataSets[sender.tag].docID).updateData(["like":count], completion: nil)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        // tableViewの高さを可変にする
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let commentVC = storyboard?.instantiateViewController(withIdentifier: "commentVC") as! CommentViewController
        commentVC.idString = dataSets[indexPath.row].docID
        commentVC.kaitouString = "\(self.dataSets[indexPath.row].userName)くんの回答\n\(self.dataSets[indexPath.row].answers)"
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
}
