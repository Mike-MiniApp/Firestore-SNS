//
//  ViewController.swift
//  FireStoreBasic
//
//  Created by 近藤米功 on 2022/06/18.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD

class ViewController: UIViewController {

    // DBの場所を指定
    let db1 = Firestore.firestore().collection("Odai").document("aRgYqZoremhOVUMDPW3E")

    let db2 = Firestore.firestore()

    var userName: String = ""
    @IBOutlet private var odaiLabel: UILabel!
    @IBOutlet var answerTextView: UITextView!

    var idString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.object(forKey: "nameKey") != nil{
            userName = UserDefaults.standard.object(forKey: "nameKey") as! String
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true

        if UserDefaults.standard.object(forKey: "documentID") != nil{
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        }else{
            // ドキュメントID（例:Answers/aRgYqZoremhOVUMDPW3E）を取得することができる
            idString = db2.collection("Answers").document().path
            // dropFirst(8)でAnswersを消している
            idString = String(idString.dropFirst(8))
            UserDefaults.standard.setValue(idString, forKey: "documentID")
        }
        print("idString",idString)
        // ロード（Odai）
        loadQuestionData()

    }

    func loadQuestionData(){
        db1.getDocument { snapShot, error in
            if error != nil{
                return
            }
            let data = snapShot?.data()
            guard let data = data else{
                return
            }
            self.odaiLabel.text = data["odaiText"] as! String
        }
    }

    @IBAction func didTapLogoutButton(_ sender: Any) {
         let firebaseAuth = Auth.auth()
               do{
                   try firebaseAuth.signOut()
                   UserDefaults.standard.removeObject(forKey: "userName")
                   UserDefaults.standard.removeObject(forKey: "documentID")
                   print("ログアウトボタン押せてる？")
               }catch let error as NSError{
                   print("エラー",error)
               }
               self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTapSendButton(_ sender: Any) {
        db2.collection("Answers").document(idString).setData(
            ["answer":answerTextView.text as Any,"userName": userName as Any,"postDate":Date().timeIntervalSince1970,"like":0,"likeFlagDic":[idString:false]]
        )
//        db2.collection("Answers").document().setData(["answer":answerTextView.text as Any,"userName":userName,"postDate":Date().timeIntervalSince1970])
        HUD.flash(.success, delay: 1.0)
        answerTextView.text = ""
    }

    @IBAction func didTapCheckAnswerButton(_ sender: Any) {
        performSegue(withIdentifier: "CheckViewVCSegue", sender: nil)
    }


}

