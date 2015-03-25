//
//  AnonymousAccount.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/23.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class AnonymousAccount: NSObject {
    
    let qiitaApiManager: QiitaApiManager = QiitaApiManager.sharedInstance
    let userDataManager: UserDataManager = UserDataManager.sharedInstance
    
    func signin(code: String, completion: (qiitaAccount: QiitaAccount?) -> Void) {
        
        self.qiitaApiManager.postAuthorize(ThirdParty.Qiita.ClientID.rawValue, clientSecret: ThirdParty.Qiita.ClientSecret.rawValue, code: code) { (token, isError) -> Void in
            
            if isError {
                completion(qiitaAccount:nil);
                return
            }
            
            // 保存
            self.userDataManager.setQiitaAccessToken(token)
            self.qiitaApiManager.setupHeader()
            self.qiitaApiManager.getAuthenticatedUser({ (item, isError) -> Void in
                if isError {
                    completion(qiitaAccount:nil)
                    return
                }
                let account = QiitaAccount(qiitaId: item!.id)
                completion(qiitaAccount:account)
            })
            
        }
    }
    
    func signout(completion: (anonymous: AnonymousAccount?) -> Void) {
        completion(anonymous: self)
    }
    
    func newEntries(page:Int, completion: (total: Int, items:[EntryEntity]) -> Void) {
        self.qiitaApiManager.getEntriesNew(page, completion: { (total, items, isError) -> Void in
            
            if isError {
                completion(total: 0, items: [EntryEntity]())
                return
            }
            
            completion(total: total, items: items)
            
        })
    }
    
    func searchEntries(page: Int, query:String, completion: (total: Int, items:[EntryEntity]) -> Void) {
        self.qiitaApiManager.getEntriesSearch(query, page: page) { (total, items, isError) -> Void in
            if isError {
                completion(total:0, items:[EntryEntity]())
                return
            }
            completion(total: total, items: items)
        }
    }
    
    func downloadEntryTitles() -> [String] {
        return [String].convert(UserDataManager.sharedInstance.entryFiles, key: "title")
    }
    
    func downloadEntryId(atIndex: Int) -> String {
        
        let item: [String: String] = UserDataManager.sharedInstance.entryFiles[atIndex]
        
        if let id = item["id"] {
            return id
        } else {
            return ""
        }
        
    }
    
    func download(entry: EntryEntity, completion: (isError: Bool) -> Void) {
        let manager: FileManager = FileManager()
        manager.save(entry.id, dataString: entry.htmlBody, completion: { (isError) -> Void in
            if isError {
                completion(isError: true)
                return
            }
            
            self.userDataManager.appendSavedEntry(entry.id, title: entry.title)
            completion(isError: false)
            return
        })
    }
    
    func pinEntryTitles() -> [String] {
        return [String].convert(self.userDataManager.pins, key: "title")
    }
    
    func pinEntryId(atIndex: Int) -> String {
        if let id = self.userDataManager.pins[atIndex]["id"] {
            return id
        } else {
            return ""
        }
    }
    
    func pin(entry: EntryEntity) {
        self.userDataManager.appendPinEntry(entry.id, entryTitle: entry.title)
    }
    
    func removePin(atIndex: Int) {
        self.userDataManager.clearPinEntry(atIndex)
    }
    
    func saveQueryTitles() -> [String] {
        return [String].convert(self.userDataManager.queries, key: "title")
    }
    
    func saveQuery(query: String, title: String) {
        self.userDataManager.appendQuery(query, label: title)
    }
    
    func removeQuery(atIndex: Int) {
        self.userDataManager.clearQuery(atIndex)
    }
    
    func existsMuteUser(userId: String) -> Bool {
        return contains(self.userDataManager.muteUsers, userId)
    }
    
    func muteUserNames() -> [String] {
        return self.userDataManager.muteUsers
    }
    
    func muteUserId(atIndex: Int) -> String {
        return self.userDataManager.muteUsers[atIndex]
    }
    
    func cancelMute(atIndex: Int) {
        self.userDataManager.clearMutedUser(self.muteUserNames()[atIndex])
    }
    func cancelMute(userId: String) {
        self.userDataManager.clearMutedUser(userId)
    }
    
    func mute(userId: String) {
        self.userDataManager.appendMuteUserId(userId)
    }
    
}