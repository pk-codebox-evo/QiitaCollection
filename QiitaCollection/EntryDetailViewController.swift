//
//  EntryDetailViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/11.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryDetailViewController: BaseViewController {
    
    typealias ParseItem = (label: String, value: String)

    // MARK: UI
    @IBOutlet weak var webView: EntryDetailView!
    
    // MARK: プロパティ
    var displayEntry: EntryEntity? = nil {
        willSet {
            self.title = newValue?.title
        }
    }
    var displayEntryId: String? = nil
    var qiitaManager: QiitaApiManager = QiitaApiManager()
    
    lazy var links: [ParseItem] = self.parseLink()
    lazy var codes: [ParseItem] = self.parseCode()
    let patternLink: String = "<a.*?href=\\\"([http|https].*?)\\\".*?>(.*?)</a>"
    let patternCode: String = "\\`{3}(.*?)\\n((.|\\n)*?)\\`{3}"
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        // したに固定メニューボタンがあるんで、bottom padding をセットしておく
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 44.0, 0)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let entry = self.displayEntry {
            self.displayEntryId = entry.id
            self.loadLocalHtml()
        } else if let entryId = self.displayEntryId {
            // 投稿IDだけ渡されてる状況なので、とってくる
            self.qiitaManager.getEntry(entryId, completion: { (item, isError) -> Void in
                if isError {
                    Toast.show("投稿を取得できませんでした...", style: JFMinimalNotificationStytle.StyleWarning)
                    return
                }
                self.displayEntry = item
                self.loadLocalHtml()
            })
        } else {
            fatalError("unknown entry....")
        }
        
    }
    
    
    // MARK: メソッド
    override func publicMenuItems() -> [PathMenuItem] {
        let menuItemShare: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "icon_share")!)
        menuItemShare.action = {() -> Void in
            self.shareEntry()
            return
        }
        let menuItemLink: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "icon_link")!)
        menuItemLink.action = {() -> Void in
            self.openLinks()
            return
        }
        let menuItemClip: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "icon_clipboard")!)
        menuItemClip.action = {() -> Void in
            self.copyCode()
            return
        }
        let menuPerson: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "icon_person")!)
        menuPerson.action = {() -> Void in
            self.moveUserDetail()
            return
        }
        let menuPin: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "icon_pin")!)
        menuPin.action = {() -> Void in
            self.confirmPinEntry()
            return
        }
        return [menuItemShare, menuItemLink, menuItemClip, menuPerson, menuPin]
    }
    
    func loadLocalHtml() {
        // テンプレート読み込み
        let path: NSString = NSBundle.mainBundle().pathForResource("entry", ofType: "html")!
        let template: NSString = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
        // テンプレートに組み込んで表示
        self.webView.loadHTMLString(NSString(format: template, self.displayEntry!.title, self.displayEntry!.htmlBody), baseURL: nil)
    }
    
    func shareEntry() {
        
        var shareItems: [AnyObject] = [
            NSString(string: self.displayEntry!.title),
            NSURL(string: self.displayEntry!.urlString)!
        ]
        
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        self.presentViewController(shareVC, animated: true) { () -> Void in
            
        }
    }
    
    func openLinks() {
        
        if self.links.count == 0 {
            
            NSNotificationCenter.defaultCenter()
                .postNotificationName(QCKeys.Notification.ShowMinimumNotification.rawValue,
                    object: nil,
                    userInfo: [
                        QCKeys.MinimumNotification.SubTitle.rawValue: "開けるリンクがありません...",
                        QCKeys.MinimumNotification.Style.rawValue: NSNumber(integer: JFMinimalNotificationStytle.StyleWarning.rawValue)
                    ])
            return
        }
        
        let makeAletAction = { (item: ParseItem) -> UIAlertAction in
            return UIAlertAction(title: item.label, style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                self.openURL(item.value)
            })
        }
        
        var actions: [UIAlertAction] = [UIAlertAction]()
        for item in self.links {
            actions.append(makeAletAction(item))
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        actions.append(cancelAction)
        
        NSNotificationCenter.defaultCenter()
            .postNotificationName(QCKeys.Notification.ShowActionSheet.rawValue,
                object: nil,
                userInfo: [
                    QCKeys.ActionSheet.Title.rawValue: "開くURLを選んで下さい",
                    QCKeys.ActionSheet.Actions.rawValue: actions
                ])
        
    }
    
    func copyCode() {
        if self.codes.count == 0 {
            
            NSNotificationCenter.defaultCenter()
                .postNotificationName(QCKeys.Notification.ShowMinimumNotification.rawValue,
                    object: nil,
                    userInfo: [
                        QCKeys.MinimumNotification.SubTitle.rawValue: "コードブロックがないようです...",
                        QCKeys.MinimumNotification.Style.rawValue: NSNumber(integer: JFMinimalNotificationStytle.StyleWarning.rawValue)
                    ])
            return
        }
        
        let makeAlertAction = { (item: ParseItem) -> UIAlertAction in
            return UIAlertAction(title: item.label, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                UIPasteboard.generalPasteboard().setValue(item.value, forPasteboardType: "public.utf8-plain-text")
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(QCKeys.Notification.ShowMinimumNotification.rawValue,
                        object: nil,
                        userInfo: [
                            QCKeys.MinimumNotification.SubTitle.rawValue: "対象のコードブロックをクリップボードにコピーしました",
                            QCKeys.MinimumNotification.Style.rawValue: NSNumber(integer: JFMinimalNotificationStytle.StyleSuccess.rawValue)
                        ])
            })
        }
        var actions: [UIAlertAction] = [UIAlertAction]()
        for item in self.codes {
            actions.append(makeAlertAction(item))
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        actions.append(cancelAction)
        
        NSNotificationCenter.defaultCenter()
            .postNotificationName(QCKeys.Notification.ShowActionSheet.rawValue,
                object: nil,
                userInfo: [
                    QCKeys.ActionSheet.Title.rawValue: "クリップボードにコピーするコードブロックを選んで下さい",
                    QCKeys.ActionSheet.Actions.rawValue: actions
                ])
    }
    
    func parseLink() -> [ParseItem] {
        return self.parseHtml(self.displayEntry!.htmlBody, pattern:self.patternLink)
    }
    
    func parseCode() -> [ParseItem] {
        return self.parseHtml(self.displayEntry!.body, pattern:self.patternCode)
    }
    
    func parseHtml(body:String, pattern: String) -> [ParseItem] {
        let nsBody: NSString = NSString(string: body)
        var error: NSError?
        let regex: NSRegularExpression? = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
        let mathes: [AnyObject]? = regex?.matchesInString(nsBody, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, nsBody.length))
        var targets: [ParseItem] = [ParseItem]()
        
        let indexLabel: Int = pattern == self.patternLink ? 2 : 1
        let indexValue: Int = pattern == self.patternLink ? 1 : 2
        
        if let objects = mathes {
            for obj in objects {
                let result: NSTextCheckingResult = obj as NSTextCheckingResult
                var label: String = nsBody.substringWithRange(result.rangeAtIndex(indexLabel))
                let value: String = nsBody.substringWithRange(result.rangeAtIndex(indexValue))
                
                if (label.isEmpty) {
                    label = value.componentsSeparatedByString("\n")[0]
                } else if (pattern == self.patternCode) {
                    let separateLabel = label.componentsSeparatedByString(":")
                    if (separateLabel.count == 2) {
                        label = separateLabel[1] + ":" + value.componentsSeparatedByString("\n")[0]
                    } else {
                        label = separateLabel[0] + ":" + value.componentsSeparatedByString("\n")[0]
                    }
                }
                let item: ParseItem = ParseItem(label:label, value:value)
                targets.append(item)
            }
        }
        return targets
    }
    
    func openURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(QCKeys.Notification.ShowMinimumNotification.rawValue,
                        object: nil,
                        userInfo: [
                            QCKeys.MinimumNotification.SubTitle.rawValue: "開くことが出来るURLではないようです…",
                            QCKeys.MinimumNotification.Style.rawValue: NSNumber(integer: JFMinimalNotificationStytle.StyleWarning.rawValue)
                        ])
            }
            
        } else {
            NSNotificationCenter.defaultCenter()
                .postNotificationName(QCKeys.Notification.ShowMinimumNotification.rawValue,
                    object: nil,
                    userInfo: [
                        QCKeys.MinimumNotification.SubTitle.rawValue: "開くことが出来るURLではないようです…",
                        QCKeys.MinimumNotification.Style.rawValue: NSNumber(integer: JFMinimalNotificationStytle.StyleWarning.rawValue)
                    ])
            return
        }
        
    }
    
    func moveUserDetail() {
        let vc: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as UserDetailViewController
        vc.displayUserId = self.displayEntry!.postUser.id
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func confirmPinEntry() {
        let action: AlertViewSender = AlertViewSender(action: { () -> Void in
            UserDataManager.sharedInstance.appendPinEntry(self.displayEntry!.id, entryTitle: self.displayEntry!.title)
            Toast.show("この投稿をpinしました", style: JFMinimalNotificationStytle.StyleSuccess)
            return
        }, title: "OK")
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil, userInfo: [
            QCKeys.AlertView.Title.rawValue    : "確認",
            QCKeys.AlertView.Message.rawValue  : "この投稿をpinしますか？",
            QCKeys.AlertView.YesAction.rawValue: action,
            QCKeys.AlertView.NoTitle.rawValue  : "Cancel"
        ])
    }
    
}
