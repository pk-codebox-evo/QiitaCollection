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
        ShowActionSheet = "QC_NotificationKey_ShowActionSheet",
        PushViewController = "QC_NotificationKey_PushViewController",
        ShowMinimumNotification = "QC_NotificationKey_MinimumNtofice",
        ShowLoading = "QC_NotificationKey_ShowLoading",
        HideLoading = "QC_NotificationKey_HideLoading",
        ShowAlertYesNo = "QC_NotificationKey_ShowAlertYesNo",
        ShowAlertInputText = "QC_NotificationKey_ShowAlertInputText",
        PresentedViewController = "QC_NotificationKey_PresentedViewController",
        ResetPublicMenuItems = "QC_NotificationKey_ResetPublicMenuItems",
        ReloadViewPager = "QC_NotificationKey_ReloadViewPager"
    }
    
    enum ActionSheet: String {
        case
        Title = "Title",
        Description = "Description",
        Actions = "Actions"
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
        NoTitle = "No-Title",
        PlaceHolder = "Place-Holder"
    }
}
