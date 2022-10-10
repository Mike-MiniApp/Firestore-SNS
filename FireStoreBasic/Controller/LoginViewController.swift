//
//  LoginViewController.swift
//  FireStoreBasic
//
//  Created by 近藤米功 on 2022/06/18.
//

import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }

    func login(){
        let name = nameTextField.text ?? ""
        //　匿名ログイン
        Auth.auth().signInAnonymously { (result, error) in
            let user = result?.user
            print(user?.uid)
            UserDefaults.standard.set(name, forKey: "nameKey")
            // 画面遷移
            self.performSegue(withIdentifier: "viewVCSegue", sender: nil)
        }

    }
    @IBAction func didTapDoneButton(_ sender: Any) {
        login()
    }

}
