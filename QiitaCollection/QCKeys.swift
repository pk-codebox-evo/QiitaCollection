//
//  QCKeys.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/11.
//  Copyright (c) 2015年 anz. All rights reserved.
//

struct QCKeys {
    
    enum Notification: String {
        case
        ShowAlertController = "QC_NotificationKey_ShowAlertController",
        ShowActivityView = "QC_NotificationKey_ShowActivityView",
        PushViewController = "QC_NotificationKey_PushViewController",
        ShowMinimumNotification = "QC_NotificationKey_MinimumNtofice",
        ShowLoadingWave = "QC_NotificationKey_ShowLoading_Wave",
        HideLoadingWave = "QC_NotificationKey_HideLoading_Wave",
        ShowAlertYesNo = "QC_NotificationKey_ShowAlertYesNo",
        ShowAlertInputText = "QC_NotificationKey_ShowAlertInputText",
        PresentedViewController = "QC_NotificationKey_PresentedViewController",
        ResetPublicMenuItems = "QC_NotificationKey_ResetPublicMenuItems",
        ReloadViewPager = "QC_NotificationKey_ReloadViewPager",
        ShowAlertOkOnly = "QC_NotificationKey_OkOnly",
        ClearGuide = "QC_NotificationKey_ClearGuide",
        ShowInterstitial = "QC_NotificationKey_Interstitial"
    }
    
    enum AlertController: String {
        case
        Title = "Title",
        Description = "Description",
        Actions = "Actions",
        Style = "Style"
    }
    
    enum ActivityView: String {
        case
        Message = "Message",
        Link = "Link",
        Others = "Others"
    }
    
    enum MinimumNotification: String {
        case
        Title = "Title",
        SubTitle = "SubTitle",
        Style = "Style"
    }
    
    enum AlertView: String {
        case
        Title = "Title",
        Message = "Message",
        YesAction = "Yes-Action",
        YesTitle = "Yes-Title",
        NoTitle = "No-Title",
        PlaceHolder = "Place-Holder",
        OtherAction = "Other-Action",
        OtherTitle = "Other-Title"
    }
    
    enum UserActivity: String {
        case
        TypeSendURLToMac = "xyz.anzfactory.qiita-collection"
    }
    
    enum Transition: String {
        case
        CenterPoint = "center-point"
    }
}
