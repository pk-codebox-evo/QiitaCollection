//
//  ParseManager.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/04/04.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ParseManager {
    
    // シングルトンパターン
    class var sharedInstance : ParseManager {
        struct Static {
            static let instance : ParseManager = ParseManager()
        }
        return Static.instance
    }
    
    init() {
        
    }
    
    class func setup() {
        Parse.setApplicationId(ThirdParty.Parse.ApplicationID.rawValue, clientKey: ThirdParty.Parse.ClientKey.rawValue)

        PFUser.enableAutomaticUser()
        let defaultACL = PFACL(user: PFUser.currentUser()!)
        // 基本的にはprivateなデータを作成する
        // もし、publicにしたい時は、save()するときに都度指定して
        defaultACL.setPublicReadAccess(false)
        defaultACL.setPublicWriteAccess(false)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
        
        // 初回で端末内に保持させるためにもsaveする
        // こうしておくと currentUser.username が設定される
        // (正しい手順かは・・ｗ)
        let currentUser = PFUser.currentUser()
        currentUser!.saveInBackgroundWithBlock { (result, error) -> Void in
            
        }
    }
    
    func isAuthorized() -> Bool {
        return !PFUser.currentUser()!.username!.isEmpty
    }
    
//    func signup(parentVC: UIViewController) {
//        let vc = PFLogInViewController()
//        vc.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.PasswordForgotten | PFLogInFields.DismissButton | PFLogInFields.Twitter
//        vc.signUpController.fields = PFSignUpFields.UsernameAndPassword | PFSignUpFields.Email | PFSignUpFields.Additional | PFSignUpFields.SignUpButton | PFSignUpFields.DismissButton
//        parentVC.presentViewController(vc, animated: true) { () -> Void in
//            
//        }
//    }
    
    func putHistory(entry: EntryEntity) {
        
        if !self.isAuthorized() {
            return
        }
        
        var data: PFObject = PFObject(className: "History")
        let user: PFUser = PFUser.currentUser()!
        
        let query: PFQuery = PFQuery(className: "History")
        query.whereKey("userName", equalTo: user.username!)
        .whereKey("entryId", equalTo: entry.id)
        query.getFirstObjectInBackgroundWithBlock { (resultData, error) -> Void in
            if let e = error {
                // 101 は notresult のエラー (該当なし)
                if e.code != 101 {
                    return
                }
                data["userName"] = user.username
                data["entryId"] = entry.id
            } else {
                data = resultData!
            }
            
            data["title"] = entry.title
            data["tags"] = TagEntity.titles(entry.tags)
            
            data.saveInBackgroundWithBlock({ (successed, error) -> Void in
                // 履歴なので失敗しようが成功しようが関知しない
            })
            
        }
    }
    
    func getHistory(page: Int, completion: (items: [HistoryEntity]) -> Void) {
        
        if !self.isAuthorized() {
            return
        }
        
        let limit: Int = 100
        let user = PFUser.currentUser()
        let query: PFQuery = PFQuery(className: "History")
        query.whereKey("userName", equalTo: user!.username!)
        .orderByDescending("updatedAt")
        query.limit = limit   // リクエストを抑えたいから多めにｗ
        query.skip = (page - 1) * limit // offset
        
        query.findObjectsInBackgroundWithBlock { (items, error) -> Void in
            
            var list: [HistoryEntity] = [HistoryEntity]()
            
            if let e = error {
                println(e)
                completion(items: list)
                return
            }
            
            if let itemList = items {
                for object in itemList {
                    if let obj = object as? PFObject {
                        list.append(HistoryEntity(object: obj))
                    }
                }
            }
            
            completion(items: list)
            
        }
    }
    
    func getWeekRanking(page: Int, completion: (items: [RankEntity]) -> Void) {
        
        let limit: Int = 20
        let user = PFUser.currentUser()
        let query: PFQuery = PFQuery(className: "RankingWeek")
        query.orderByAscending("rank")
        query.limit = limit
        
        query.findObjectsInBackgroundWithBlock { (items, error) -> Void in
            
            var list: [RankEntity] = [RankEntity]()
            
            if let e = error {
                println(e)
                completion(items: list)
                return
            }
            
            if let itemList = items {
                for object in itemList {
                    if let obj = object as? PFObject {
                        list.append(RankEntity(object: obj))
                    }
                }
            }
            
            completion(items: list)
            
        }
    }
    
    func getAdventList(year: Int, page: Int, completion: (items: [KimonoEntity]) -> Void) {
        
        let limit: Int = 50
        let user = PFUser.currentUser()
        let query: PFQuery = PFQuery(className: "KimonoApis")
        query.whereKey("year", equalTo: year)
        query.orderByAscending("title")
        query.limit = limit   // リクエストを抑えたいから多めにｗ
        query.skip = (page - 1) * limit // offset
        
        query.findObjectsInBackgroundWithBlock { (items, error) -> Void in
            
            var list: [KimonoEntity] = [KimonoEntity]()
            
            if let e = error {
                println(e)
                completion(items: list)
                return
            }
            
            if let itemList = items {
                for object in itemList {
                    if let obj = object as? PFObject {
                        list.append(KimonoEntity(object: obj))
                    }
                }
            }
            
            completion(items: list)
            
        }
    }
    
    func getAdventEntries(objectId: String, completion: (items: [AdventEntity]) -> Void) {
        
        let user = PFUser.currentUser()
        let query: PFQuery = PFQuery(className: "Advents")
        query.whereKey("adventId", equalTo: objectId)
        query.orderByAscending("date")
        
        query.findObjectsInBackgroundWithBlock { (items, error) -> Void in
            
            var list: [AdventEntity] = [AdventEntity]()
            
            if let e = error {
                println(e)
                completion(items: list)
                return
            }
            
            if let itemList = items {
                for object in itemList {
                    if let obj = object as? PFObject {
                        list.append(AdventEntity(object: obj))
                    }
                }
            }
            
            completion(items: list)
            
        }
    }
}
