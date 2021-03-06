//
//  AccountManager.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/23.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import Foundation

class AccountManager {
    
    class func account() -> AnonymousAccount {
        
        if ( AccountManager.isAuthorized() ) {
            return QiitaAccount()
        } else {
            return AnonymousAccount()
        }
        
    }
    
    class func isAuthorized() -> Bool {
        return UserDataManager.sharedInstance.isAuthorizedQiita()
    }
    
}