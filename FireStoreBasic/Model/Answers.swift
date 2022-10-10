//
//  AnswersModel.swift
//  FireStoreBasic
//
//  Created by 近藤米功 on 2022/06/19.
//

import Foundation
struct Answers{
    let answers: String
    let userName: String
    let docID: String
    let likeCount: Int
    let likeFlagDic: Dictionary<String, Any>
}
