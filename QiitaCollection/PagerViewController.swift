//
//  PagerViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/09.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

// selectionHandlerにセットすると自動でよばれてしまって使いづらいので…
class QCGridMenuItem: CNPGridMenuItem {
    
    typealias TapAction = (item: QCGridMenuItem) -> Void
    var action: TapAction? = nil
    var center: CGPoint? = nil
    
}

class PagerViewController: ViewPagerController, ViewPagerDelegate, ViewPagerDataSource, CNPGridMenuDelegate {
    
    typealias ViewPagerItem = (title:String, identifier:String, query:String, type: Int)

    // MARK: プロパティ
    var leftBarItem: UIBarButtonItem?
    var viewPagerItems: [ViewPagerItem] = [ViewPagerItem]()
    lazy var menu: CNPGridMenu = self.makeMenu()
    var reloadViewPager: Bool = false
    var viewPagerTabWidth: CGFloat = 120.0
    var viewPagerTabHeight: CGFloat = 0.0
    lazy var account: AnonymousAccount = self.setupAccount();
    var barItemSearch: UIBarButtonItem? = nil
 
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as? String
        self.setupNavigation()
        
        self.barItemSearch = UIBarButtonItem(image: UIImage(named: "bar_item_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapSearch")
        let rightButtons: [UIBarButtonItem] = [
            UIBarButtonItem(image: UIImage(named: "bar_item_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapSetting"),
            self.barItemSearch!
        ]
        self.navigationItem.rightBarButtonItems = rightButtons
        rightButtons[1].showGuide(GuideManager.GuideType.SearchIcon)
        
        self.setupViewControllers()
        
        // デフォルトVC
        self.dataSource = self
        self.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveReloadViewPager", name: QCKeys.Notification.ReloadViewPager.rawValue, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.reloadViewPager {
            self.reloadViewPager = false
            self.setupViewControllers()
            self.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: メソッド
    func setupAccount() -> AnonymousAccount {
        return AccountManager.account()
    }
    
    func setupViewControllers() {
        self.viewPagerItems.removeAll(keepCapacity: false)
        self.viewPagerItems.append(ViewPagerItem(title: "週間ランキング", identifier:"EntryCollectionVC", query:"", type: EntryCollectionViewController.ListType.WeekRanking.rawValue))
        self.viewPagerItems.append(ViewPagerItem(title: "新着", identifier:"EntryCollectionVC", query:"", type: EntryCollectionViewController.ListType.New.rawValue))
        
        // クエリで回す
        let queries: [[String: String]] = self.account.saveQueries()
        if !queries.isEmpty {
            for queryItem in queries {
                self.viewPagerItems.append(ViewPagerItem(title: queryItem["title"]!, identifier:"EntryCollectionVC", query:queryItem["query"]!, type: EntryCollectionViewController.ListType.Search.rawValue))
            }
        }
        
        // advent
        self.viewPagerItems.append(ViewPagerItem(title:"Advent Calendar", identifier:"AdventListVC", query: "", type: 0))
        
        // 保存した投稿リストがあるか
        if self.account.hasDownloadFiles() {
            self.viewPagerItems.append(ViewPagerItem(title:"保存した投稿", identifier:"SimpleListVC", query: "", type: 0))
        }
        
        // 認証済みなら末尾にmypage 
        // アカウントの型判定だけでやりたいけど
        // 最初の認証直後から account が QiitaAccount になるまで時間差があるので
        // userdata も参考にする
        if self.account is QiitaAccount || UserDataManager.sharedInstance.isAuthorizedQiita() {
            self.viewPagerItems.append(ViewPagerItem(title:"マイページ", identifier:"UserDetailVC", query:"", type: 0))
        }
        
        let width: CGFloat = self.view.frame.size.width / CGFloat(self.viewPagerItems.count)
        if width > 120.0 {
            self.viewPagerTabWidth = width
        } else {
            self.viewPagerTabWidth = 120.0
        }

    }
    func makeMenu() -> CNPGridMenu {
        let menuItemMuteUsers: QCGridMenuItem = QCGridMenuItem()
        menuItemMuteUsers.icon = UIImage(named: "icon_circle_slash")
        menuItemMuteUsers.title = "Mute User"
        menuItemMuteUsers.action = {(item) -> Void in
            self.openMuteUserList(item)
            return
        }
        
        let menuItemPinEntries: QCGridMenuItem = QCGridMenuItem()
        menuItemPinEntries.icon = UIImage(named: "icon_pin")
        menuItemPinEntries.title = "Pins"
        menuItemPinEntries.action = {(item) -> Void in
            self.openPinEntryList(item)
            return
        }
        
        let menuItemQuery: QCGridMenuItem = QCGridMenuItem()
        menuItemQuery.icon = UIImage(named: "icon_lock")
        menuItemQuery.title = "Query"
        menuItemQuery.action = {(item) -> Void in
            self.openQueryList(item)
        }
        
        let menuItemSigin: QCGridMenuItem = QCGridMenuItem()
        if AccountManager.isAuthorized() {
            menuItemSigin.icon = UIImage(named: "icon_sign_out")
            menuItemSigin.title = "Sign out"
            menuItemSigin.action = {(item) -> Void in
                self.confirmSignout()
            }
        } else {
            menuItemSigin.icon = UIImage(named: "icon_sign_in")
            menuItemSigin.title = "Sign in"
            menuItemSigin.action = {(item) -> Void in
                self.openSigninVC(item)
            }
        }
        
        let menuReview: QCGridMenuItem = QCGridMenuItem()
        menuReview.icon = UIImage(named: "icon_megaphone")
        menuReview.title = "Review"
        menuReview.action = {(item) -> Void in
            self.moveReview()
            return
        }
        
        let menuWiki: QCGridMenuItem = QCGridMenuItem()
        menuWiki.icon = UIImage(named: "icon_question")
        menuWiki.title = "Help"
        menuWiki.action = {(item) -> Void in
            self.openWiki()
            return
        }
        
        let menuItemInfo: QCGridMenuItem = QCGridMenuItem()
        menuItemInfo.icon = UIImage(named: "icon_info")
        menuItemInfo.title = "About App"
        menuItemInfo.action = {(item) -> Void in
            self.openAboutApp(item)
        }
        
        let menuImageSettings: QCGridMenuItem = QCGridMenuItem()
        menuImageSettings.icon = UIImage(named: "icon_media")
        menuImageSettings.title = "Cover"
        menuImageSettings.action = {(item) -> Void in
            self.openImageSetting(item)
        }
        
        var items = [menuItemMuteUsers, menuItemPinEntries, menuItemQuery, menuImageSettings, menuReview, menuWiki, menuItemInfo];
        // 未認証なら最初にsign in 認証済みなら最後に sign out
        if AccountManager.isAuthorized() {
            items.append(menuItemSigin)
        } else {
            items.insert(menuItemSigin, atIndex: 0)
        }
        let menu: CNPGridMenu = CNPGridMenu(menuItems: items)
        menu.delegate = self
        return menu
    }
    
    func tapSetting() {

        self.presentGridMenu(self.menu, animated: true) { () -> Void in
            
        }
    }
    
    func tapSearch() {
        let vc: SearchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchVC") as! SearchViewController
        vc.callback = {(searchVC: SearchViewController, q: String) -> Void in
            
            let entriesVC: EntryCollectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryCollectionVC") as! EntryCollectionViewController
            entriesVC.ShowType = EntryCollectionViewController.ListType.Search
            entriesVC.query = q
            entriesVC.title = "検索結果"
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: entriesVC)
            
            searchVC.dismiss()
            
        }
        if let v = self.barItemSearch?.valueForKey("view") as? UIView {
            vc.transitionSenderPoint = self.navigationController?.navigationBar.convertPoint(v.center, toView: self.view)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    func openMuteUserList(item: QCGridMenuItem) {
        let mutedUsers: [String] = self.account.muteUserNames()
        if (mutedUsers.isEmpty) {
            Toast.show("ミュートユーザーが追加されていません", style: JFMinimalNotificationStytle.StyleInfo)
            return
        }
        
        let muteVC: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as! SimpleListViewController
        muteVC.items = mutedUsers
        muteVC.title = "ミュートリスト"
        muteVC.cellGuide = GuideManager.GuideType.MuteListSwaipeCell
        muteVC.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            
            // まずは閉じる
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                // user詳細
                let userVC: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailViewController
                userVC.displayUserId = self.account.muteUserId(index)
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: userVC)
            })
            
        }
        muteVC.swipeCellCallback = {(vc: SimpleListViewController, cell: SlideTableViewCell, index:Int) -> Void in
            self.account.cancelMute(index)
            vc.removeItem(index)
            Toast.show("ミュートを解除しました", style: JFMinimalNotificationStytle.StyleSuccess, title: "", targetView: vc.view)
        }
        
        if let p = item.center {
            muteVC.transitionSenderPoint = p
        }
        NSNotificationCenter.defaultCenter().postNotificationName(
            QCKeys.Notification.PresentedViewController.rawValue,
            object: muteVC
        )
    }
    
    func openPinEntryList(item: QCGridMenuItem) {
        
        let pins: [String] = self.account.pinEntryTitles()
        if (pins.isEmpty) {
            Toast.show("pinした投稿がありません", style: JFMinimalNotificationStytle.StyleInfo)
            return
        }
        
        let vc: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as! SimpleListViewController
        vc.items = pins
        vc.title = "pinリスト"
        vc.cellGuide = GuideManager.GuideType.PinListSwaipeCell
        vc.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            
            // まずは閉じる
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                // 記事詳細
                let entryVC: EntryDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as! EntryDetailViewController
                entryVC.displayEntryId = self.account.pinEntryId(index)
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: entryVC)
            })
            
        }
        vc.swipeCellCallback = {(vc: SimpleListViewController, cell: SlideTableViewCell, index: Int) -> Void in
            self.account.removePin(index)
            // 再作成
            vc.removeItem(index)
            Toast.show("pinした投稿を解除しました", style: JFMinimalNotificationStytle.StyleSuccess, title: "", targetView: vc.view)
        }
        if let p = item.center {
            vc.transitionSenderPoint = p
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
        
    }
    
    func openQueryList(item: QCGridMenuItem) {
        let titles = self.account.saveQueryTitles()
        
        if titles.isEmpty {
            Toast.show("保存した検索がありません...", style: JFMinimalNotificationStytle.StyleInfo)
            return
        }
        
        let vc: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as! SimpleListViewController
        vc.items = titles
        vc.title = "保存した検索条件"
        vc.cellGuide = GuideManager.GuideType.QueryListSwipeCell
        vc.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            // 特に何もしない
        }
        vc.swipeCellCallback = {(vc: SimpleListViewController, cell: SlideTableViewCell, index: Int) -> Void in
            // 削除処理
            self.account.removeQuery(index)
            // ViewPager再構成
            self.setupViewControllers()
            self.reloadData()
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            return
        }
        if let p = item.center {
            vc.transitionSenderPoint = p
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    func openSigninVC(item: QCGridMenuItem) {
        let vc: SigninViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SigninVC") as! SigninViewController
        vc.authorizationAction = {(viewController: SigninViewController, qiitaAccount: QiitaAccount) -> Void in
            // ViewPager再構成
            self.menu = self.makeMenu()
            self.setupViewControllers()
            self.reloadData()
            // 認証ユーザーの情報を取ってIDだけ保持しておく (self判定したいんで...)
            self.account = qiitaAccount
            viewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            return
        }
        if let p = item.center {
            vc.transitionSenderPoint = p
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    func openWiki() {
        let reviewUrl: NSURL = NSURL(string: App.URL.Wiki.string())!
        
        if UIApplication.sharedApplication().canOpenURL(reviewUrl) {
            UIApplication.sharedApplication().openURL(reviewUrl)
        }
    }
    
    func moveReview() {
        
        let reviewUrl: NSURL = NSURL(string: App.URL.Review.string())!
        
        if UIApplication.sharedApplication().canOpenURL(reviewUrl) {
            UIApplication.sharedApplication().openURL(reviewUrl)
        }
    }
    
    func openAboutApp(item: QCGridMenuItem) {
        let vc: AboutAppViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AboutAppVC") as! AboutAppViewController
        if let p = item.center {
            vc.transitionSenderPoint = p
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    func openImageSetting(item: QCGridMenuItem) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ImageSettingsVC") as! ImageSettingsViewController
        if let p = item.center {
            vc.transitionSenderPoint = p
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    func confirmSignout() {
        
        if self.account is QiitaAccount == false {
            return
        }
        
        let actionDestructive: UIAlertAction = UIAlertAction(title: "Sign Out", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            
            self.account.signout({ (anonymous) -> Void in
                if anonymous == nil {
                    Toast.show("サインアウトに失敗しました…", style: JFMinimalNotificationStytle.StyleError)
                    return
                }
                self.account = anonymous!
                self.menu = self.makeMenu()
                self.setupViewControllers()
                self.reloadData()
            })
            
        }
        
        let actionCancel: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        
        let args = [
            QCKeys.AlertController.Style.rawValue      : UIAlertControllerStyle.Alert.rawValue,
            QCKeys.AlertController.Title.rawValue      : "確認",
            QCKeys.AlertController.Description.rawValue: "サインアウトしてしまうとリクエスト制限が厳しくなりますが本当によろしいですか？",
            QCKeys.AlertController.Actions.rawValue    : [
                actionDestructive,
                actionCancel
            ]
        ]
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertController.rawValue, object: self, userInfo: args as [NSObject : AnyObject])
        
    }
    
    // MARK: NSNotification
    func receiveReloadViewPager() {
        self.reloadViewPager = true
    }
    
    // MARK: ViewPagerDatasource
    func numberOfTabsForViewPager(viewPager: ViewPagerController!) -> UInt {
        return UInt(self.viewPagerItems.count)
    }
    func viewPager(viewPager: ViewPagerController!, viewForTabAtIndex index: UInt) -> UIView! {
        let current: ViewPagerItem = self.viewPagerItems[Int(index)]
        
        let title: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.viewPagerTabWidth, height: self.viewPagerTabHeight))
        title.text = current.title
        title.font = UIFont.boldSystemFontOfSize(14.0)
        title.textColor = UIColor.textBase()
        title.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        title.textAlignment = NSTextAlignment.Center
        return title
    }
    func viewPager(viewPager: ViewPagerController!, contentViewControllerForTabAtIndex index: UInt) -> UIViewController! {
        
        let current: ViewPagerItem = self.viewPagerItems[Int(index)]
        let vc: UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier(current.identifier) as! UIViewController
        
        if vc is EntryCollectionViewController {
            (vc as! EntryCollectionViewController).ShowType = EntryCollectionViewController.ListType(rawValue: current.type)!
            (vc as! EntryCollectionViewController).query = current.query
        } else if vc is SimpleListViewController {
            let simpleVC: SimpleListViewController = vc as! SimpleListViewController
            
            simpleVC.removeNavigationBar = true
            simpleVC.items = self.account.downloadEntryTitles()
            simpleVC.swipableCell = true
            simpleVC.swipeCellCallback = {(vc: SimpleListViewController, cell: SlideTableViewCell, index: Int) -> Void in
                self.account.removeLocalEntry(index, completion: { (isError, titles) -> Void in
                    if isError {
                        Toast.show("削除失敗しました...", style: JFMinimalNotificationStytle.StyleError)
                        return
                    }
                    vc.refresh(titles)
                    Toast.show("ダウンロードした投稿ファイルを削除しました", style: JFMinimalNotificationStytle.StyleSuccess)
                })
            }
            simpleVC.tapCallback = {(vc:SimpleListViewController, index:Int) -> Void in
                
                let entryDetail: EntryDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as! EntryDetailViewController
                entryDetail.displayEntryId = self.account.downloadEntryId(index)
                entryDetail.useLocalFile = true
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: entryDetail)
                
            }
        } else if vc is UserDetailViewController {
            (vc as! UserDetailViewController).showAuthenticatedUser = true
        }
        return vc
    }
    
    // MARK: ViewPagerDelegate
    func viewPager(viewPager: ViewPagerController!, colorForComponent component: ViewPagerComponent, withDefault color: UIColor!) -> UIColor! {
        switch component {
        case ViewPagerComponent.TabsView:
            return UIColor.backgroundPagerTab()
        case ViewPagerComponent.Indicator:
            return UIColor.backgroundAccent()
        default:
            return color
        }
    }
    
    func viewPager(viewPager: ViewPagerController!, valueForOption option: ViewPagerOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case ViewPagerOption.CenterCurrentTab:
            return 1.0
        case ViewPagerOption.TabWidth:
            return self.viewPagerTabWidth
        case ViewPagerOption.TabHeight:
            // デフォルト値を保持したいだけなのでスルーさせる
            self.viewPagerTabHeight = value
            fallthrough
        default:
            return value
        }
    }
    
    // MARK: CNPGridMenuDelegate
    func gridMenu(menu: CNPGridMenu!, didTapOnItem item: CNPGridMenuItem!) {
        
        var i  = 0
        for i = 0; i < menu.menuItems.count; i++ {
            if item == menu.menuItems[i] as! CNPGridMenuItem {
                break
            }
        }
        
        var targetCell = menu.collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
        
        menu.dismissGridMenuAnimated(true, completion: { () -> Void in
            let qcitem = item as! QCGridMenuItem
            if let cell = targetCell {
                qcitem.center = menu.collectionView!.convertPoint(cell.center, toView: menu.collectionView!.superview)
            }
            qcitem.action?(item: qcitem)
            return
        })
    }
    
    func gridMenuDidTapOnBackground(menu: CNPGridMenu!) {
        menu.dismissGridMenuAnimated(true, completion: { () -> Void in
            
        })
    }
    
}
