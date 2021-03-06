//
//  TopNavigationViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class TopNavigationController: UINavigationController, UINavigationControllerDelegate, PathMenuDelegate {
    
    // MARK: プロパティ
    lazy var notice: JFMinimalNotification = self.makeNotice()
    var alertView: SCLAlertView = SCLAlertView()
    var isDidAppear: Bool = false
    lazy var publicMenu: PathMenu = self.makePublicMenu()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AdManager.sharedInstance.setupInterstitial()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.delegate = self;
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.textNavigationBar()]
        self.navigationBar.barTintColor = UIColor.backgroundNavigationBar()
        self.navigationBar.tintColor = UIColor.textNavigationBar()
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "receiveShowAlertController:", name: QCKeys.Notification.ShowAlertController.rawValue, object: nil)
        center.addObserver(self, selector: "receiveShowActivityView:", name: QCKeys.Notification.ShowActivityView.rawValue, object: nil)
        center.addObserver(self, selector: "receivePushViewController:", name: QCKeys.Notification.PushViewController.rawValue, object: nil)
        center.addObserver(self, selector: "receiveShowMinimumNotification:", name: QCKeys.Notification.ShowMinimumNotification.rawValue, object: nil)
        center.addObserver(self, selector: "receiveConfirmYesNoAlert:", name: QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil)
        center.addObserver(self, selector: "receivePresentedViewController:", name: QCKeys.Notification.PresentedViewController.rawValue, object: nil)
        center.addObserver(self, selector: "receiveShowAlertInputText:", name: QCKeys.Notification.ShowAlertInputText.rawValue, object: nil)
        center.addObserver(self, selector: "receiveResetPublicMenuItems:", name: QCKeys.Notification.ResetPublicMenuItems.rawValue, object: nil)
        center.addObserver(self, selector: "receiveShowAlertOkOnly:", name: QCKeys.Notification.ShowAlertOkOnly.rawValue, object: nil)
        center.addObserver(self, selector: "receiveShowInterstitial:", name: QCKeys.Notification.ShowInterstitial.rawValue, object: nil)
        
        self.view.addSubview(self.publicMenu)
        self.publicMenu.startPoint = CGPoint(x: self.view.frame.size.width * 0.5, y: self.view.frame.height - 16)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.isDidAppear = true
        self.view.bringSubviewToFront(self.publicMenu)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.isDidAppear = false
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: メソッド
    
    func makePublicMenu() -> PathMenu {
        let startItem: PathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_three_bar")!)
        let menu: PathMenu = PathMenu(frame: self.view.bounds, startItem: startItem, optionMenus: [])
        menu.delegate = self
        menu.startButton.alpha = 0.4
        menu.nearRadius = 90.0
        menu.endRadius = 100.0
        menu.farRadius = 120.0
        return menu
    }
    
    func makeNotice() -> JFMinimalNotification {
        let notice: JFMinimalNotification = JFMinimalNotification(style: JFMinimalNotificationStytle.StyleDefault, title: " ", subTitle: " ", dismissalDelay: 2.0) { () -> Void in
        }
        notice.setTitleFont(UIFont(name: "HiraKakuProN-W6", size: 14.0))
        notice.setSubTitleFont(UIFont(name: "Hiragino Kaku Gothic ProN", size: 12.0))
        self.view.addSubview(notice)
        notice.layoutIfNeeded()
        return notice
    }
    
    func preShowAlert() -> Bool {
        self.alertView = SCLAlertView()
        self.alertView.showAnimationType = .SlideInFromTop
        self.alertView.hideAnimationType = .SlideOutToTop
        return true
    }
    
    func hideAlert() {

        if self.alertView.view.superview != nil {
            self.alertView.hideView()
        }
        
    }
    
    func resetPublicMenuItems(viewController: BaseViewController) {
        self.publicMenu.menusArray = (viewController as BaseViewController).publicMenuItems()
        self.publicMenu.hidden = self.publicMenu.menusArray.isEmpty
        if !self.publicMenu.hidden {
            
            self.publicMenu.menuWholeAngle = CGFloat(M_PI) - CGFloat(M_PI/Double(self.publicMenu.menusArray.count))
            self.publicMenu.rotateAngle = -CGFloat(M_PI_2) + CGFloat(M_PI/Double(self.publicMenu.menusArray.count)) * 1/2
            
            self.publicMenu.startButton.showGuide(GuideManager.GuideType.PublicContextMenu, inView: self.view)
        }
        
    }
    
    // MARK: NSNotification 受信処理
    
    func receiveShowAlertController(notification: NSNotification) {
        let args: [NSObject: AnyObject] = notification.userInfo!
        let vc: UIViewController = notification.object as? UIViewController ?? self.topViewController
        
        let title: String = args[QCKeys.AlertController.Title.rawValue] as? String ?? ""
        let desc: String = args[QCKeys.AlertController.Description.rawValue] as? String ?? ""
        let style: UIAlertControllerStyle = UIAlertControllerStyle(rawValue: (args[QCKeys.AlertController.Style.rawValue] as? Int ?? UIAlertControllerStyle.ActionSheet.rawValue))!
        
        let alertController: UIAlertController = UIAlertController(title: title, message: desc, preferredStyle: style)
        alertController.popoverPresentationController?.sourceView = vc.view
        // TODO: 表示位置を受け取れるようにする (あとArrowDirectionも)
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.size.width * 0.5, y: self.view.frame.size.height, width: 0, height: 0 )
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        
        if let actions: [UIAlertAction] = args[QCKeys.AlertController.Actions.rawValue] as? [UIAlertAction] {
            for action: UIAlertAction in actions {
                alertController.addAction(action)
            }
            
        }
        
        self.presentViewController(alertController, animated: true) { () -> Void in
            
        }
        
    }
    
    func receiveShowActivityView(notification: NSNotification) {
        let args: [NSObject: AnyObject] = notification.userInfo!
        let vc: UIViewController = notification.object! as! UIViewController
        
        let message: String = args[QCKeys.ActivityView.Message.rawValue]! as! String
        let link: String = args[QCKeys.ActivityView.Link.rawValue] as? String ?? ""
        let others: [UIActivity]? = args[QCKeys.ActivityView.Others.rawValue] as? Array ?? nil
        
        var shareItems: [AnyObject] = [
            NSString(string: message)
        ]
        if !link.isEmpty {
            shareItems.append(NSURL(string: link)!)
        }
        
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: others)
        shareVC.popoverPresentationController?.sourceView = vc.view// TODO: 表示位置を受け取れるようにする (あとArrowDirectionも)
        shareVC.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.size.width * 0.5, y: self.view.frame.size.height, width: 0, height: 0 )
        shareVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        vc.presentViewController(shareVC, animated: true) { () -> Void in
            
        }
    }
    
    func receivePushViewController(notification: NSNotification) {
        let vc: UIViewController = notification.object! as! UIViewController
        self.pushViewController(vc, animated: true)
    }
    
    func receivePresentedViewController(notification: NSNotification) {
        let vc: UIViewController = notification.object! as! UIViewController
        
        if let baseVC = vc as? BaseViewController, let center = notification.userInfo?[QCKeys.Transition.CenterPoint.rawValue] as? NSValue {
            baseVC.transitionSenderPoint = center.CGPointValue()
        }
        self.presentViewController(vc, animated: true) { () -> Void in
            
        }
    }
    
    func receiveShowMinimumNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        
        // 表示対象viewガ設定されていたらそっちにうつす
        if let targetView: UIView = notification.object as? UIView {
            self.notice.removeFromSuperview()
            targetView.addSubview(self.notice)
        } else if self.notice.superview == nil || self.notice.superview! != self.view {
            self.notice.removeFromSuperview()
            self.view.addSubview(self.notice)
        }
        
        var title: String = userInfo[QCKeys.MinimumNotification.Title.rawValue] as? String ?? ""
        let subTitle: String = userInfo[QCKeys.MinimumNotification.SubTitle.rawValue] as? String ?? ""
        let styleNumber: NSNumber = userInfo[QCKeys.MinimumNotification.Style.rawValue] as! NSNumber
        let style: JFMinimalNotificationStytle = JFMinimalNotificationStytle(rawValue: styleNumber.integerValue) ?? JFMinimalNotificationStytle.StyleDefault
        
        if (title.isEmpty) {
            switch style {
            case .StyleDefault:
                title = "(´・ω・`)"
            case .StyleInfo:
                title = "(｡･ω･｡)"
            case .StyleSuccess:
                title = "٩( 'ω' )و"
            case .StyleWarning:
                title = "ヾ(･ω･´;)ﾉ"
            case .StyleError:
                title = "Σ(°Д°；≡；°д°)"
            }
        }
        
        self.notice.titleLabel.text = title;
        self.notice.subTitleLabel.text = subTitle
        self.notice.setStyle(style, animated: false)
        
        self.notice.show()
    }
    
    
    func receiveShowLoading() {
        
        if !self.preShowAlert() {
            return
        }
        self.alertView.showAnimationType = .FadeIn
        self.alertView.showWaiting(self, title: "Loading...", subTitle: "少々お待ちください...m(_ _)m", closeButtonTitle: nil, duration: 0.0);
    }
    func receiveHideLoading() {
        self.alertView.hideAnimationType = .FadeOut
        self.hideAlert()
    }
    
    func receiveConfirmYesNoAlert(notification: NSNotification) {
        
        self.preShowAlert()
        
        let userInfo = notification.userInfo!
        
        let title: String = userInfo[QCKeys.AlertView.Title.rawValue] as? String ?? "注意"
        let message: String = userInfo[QCKeys.AlertView.Message.rawValue]! as! String    // 必須なんで想定外だったら落とす
        let noTiltle: String = userInfo[QCKeys.AlertView.NoTitle.rawValue] as? String ?? "いいえ"
        
        // yesアクションは必須
        let yesAction = userInfo[QCKeys.AlertView.YesAction.rawValue]! as! AlertViewSender
        self.alertView.addButton(yesAction.title.isEmpty ? "はい" : yesAction.title, actionBlock: yesAction.action)
        
        self.alertView.showWarning(self, title: title, subTitle: message, closeButtonTitle: noTiltle, duration: 0.0);
        
    }
    
    func receiveShowAlertOkOnly(notification: NSNotification) {
        self.preShowAlert()
        
        let userInfo = notification.userInfo!
        
        let title: String = userInfo[QCKeys.AlertView.Title.rawValue] as? String ?? "お知らせ"
        let message: String = userInfo[QCKeys.AlertView.Message.rawValue]! as! String    // 必須なんで想定外だったら落とす
        let noTiltle: String = userInfo[QCKeys.AlertView.NoTitle.rawValue] as? String ?? "OK"
        
        self.alertView.showInfo(self, title: title, subTitle: message, closeButtonTitle: noTiltle, duration: 0.0);
    }
    
    func receiveShowAlertInputText(notification: NSNotification) {
        
        self.preShowAlert()
        
        let userInfo = notification.userInfo!
        
        let editField: UITextField = self.alertView.addTextField(userInfo[QCKeys.AlertView.PlaceHolder.rawValue] as? String ?? "")
        let title: String = userInfo[QCKeys.AlertView.Title.rawValue] as? String ?? "info"
        let message: String = userInfo[QCKeys.AlertView.Message.rawValue]! as! String    // 必須なんで想定外だったら落とす
        let noTiltle: String = userInfo[QCKeys.AlertView.NoTitle.rawValue] as? String ?? "いいえ"
        
        // yesアクションは必須
        let yesAction = userInfo[QCKeys.AlertView.YesAction.rawValue]! as! AlertViewSender
        var validationBlock: SCLValidationBlock = {() -> Bool in
            return true
        }
        if let validation = yesAction.validation {
            validationBlock = {() -> Bool in
                return validation(editField)
            }
        }
        let action: SCLActionBlock = {() -> Void in
            yesAction.actionWithText?(editField)
            return
        }
        self.alertView.addButton(yesAction.title, validationBlock: validationBlock, actionBlock: action)
        
        self.alertView.showEdit(self, title: title, subTitle: message, closeButtonTitle: noTiltle, duration: 0.0);
        
    }
    
    func receiveShowCustomAlert(notification: NSNotification) {
        self.preShowAlert()
        
        let userInfo = notification.userInfo!
        
        let title: String = userInfo[QCKeys.AlertView.Title.rawValue] as? String ?? "お知らせ"
        let message: String = userInfo[QCKeys.AlertView.Message.rawValue]! as! String    // 必須なんで想定外だったら落とす
        let yesTitle: String = userInfo[QCKeys.AlertView.YesTitle.rawValue] as! String
        let yesAction = userInfo[QCKeys.AlertView.YesAction.rawValue]! as! AlertViewSender
        self.alertView.addButton(yesTitle, actionBlock: yesAction.action)
        
        let noTiltle: String = userInfo[QCKeys.AlertView.NoTitle.rawValue] as! String
        
        if let otherTitle = userInfo[QCKeys.AlertView.OtherTitle.rawValue] as? String,
            let otherAction = userInfo[QCKeys.AlertView.OtherAction.rawValue] as? AlertViewSender {
            self.alertView.addButton(otherTitle, actionBlock: otherAction.action)
        }
        
        self.alertView.showInfo(self, title: title, subTitle: message, closeButtonTitle: noTiltle, duration: 0.0);
    }
    
    func receiveResetPublicMenuItems(notification: NSNotification) {
        if let vc: AnyObject = notification.object {
            if vc is BaseViewController {
                self.resetPublicMenuItems(vc as! BaseViewController)
            }
        }
    }
    
    func receiveShowInterstitial(notification: NSNotification) {
        AdManager.sharedInstance.showInterstitial(self.topViewController)
    }
    
    // MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        viewController.navigationItem.backBarButtonItem = backButton;
        
        if viewController is BaseViewController {
            self.resetPublicMenuItems(viewController as! BaseViewController)
        } else {
            self.publicMenu.hidden = true
        }
        
        if self.childViewControllers.count > 2 {
            self.navigationBar.showGuide(GuideManager.GuideType.BackTopGesture, inView: self.view)
        }
    }
    
    // MARK: PathMenuDelegate
    func pathMenu(menu: PathMenu, didSelectIndex idx: Int) {
        if let item = menu.menusArray[idx] as? QCPathMenuItem {
            item.action?(sender: item)
        }
    }
    func pathMenuDidFinishAnimationClose(menu: PathMenu) {
        for item in menu.menusArray {
            item.hidden = true
        }
        menu.startButton.alpha = 0.4
    }
    func pathMenuWillAnimateOpen(menu: PathMenu) {
        menu.startButton.alpha = 1.0
        for item in menu.menusArray {
            item.hidden = false
        }
    }
        
}


// NSObjectのサブクラスじゃないと NSNotification に乗っけられない
class AlertViewSender: NSObject {
    
    typealias AlertValidation = (UITextField) -> Bool
    typealias AlertActionWithText = (UITextField) -> Void
    
    let action: SCLActionBlock?
    let actionWithText: AlertActionWithText?
    let title: String
    var validation: AlertValidation? = nil
    
    init (action: SCLActionBlock?, title: String) {
        self.action = action
        self.title = title
        self.validation = nil
        self.actionWithText = nil
    }
    
    init (validation: AlertValidation, action: AlertActionWithText?, title: String) {
        self.validation = validation
        self.actionWithText = action
        self.title = title
        self.action = nil
    }
}


