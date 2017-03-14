/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.1
*/

@import Foundation;

typedef NS_OPTIONS(NSInteger, JMMenuActionsViewAction) {
    JMMenuActionsViewAction_None            = 0,
    JMMenuActionsViewAction_MakeFavorite    = 1 << 0,
    JMMenuActionsViewAction_MakeUnFavorite  = 1 << 1,
    JMMenuActionsViewAction_Refresh         = 1 << 2,
    JMMenuActionsViewAction_Filter          = 1 << 3,
    JMMenuActionsViewAction_Edit            = 1 << 4,
    JMMenuActionsViewAction_EditFilters     = 1 << 5,
    JMMenuActionsViewAction_Sort            = 1 << 6,
    JMMenuActionsViewAction_Save            = 1 << 7,
    JMMenuActionsViewAction_Delete          = 1 << 8,
    JMMenuActionsViewAction_Rename          = 1 << 9,
    JMMenuActionsViewAction_SelectAll       = 1 << 10,
    JMMenuActionsViewAction_ClearSelections = 1 << 11,
    JMMenuActionsViewAction_Run             = 1 << 12,
    JMMenuActionsViewAction_Print           = 1 << 13,
    JMMenuActionsViewAction_Info            = 1 << 14,
    JMMenuActionsViewAction_OpenIn          = 1 << 15,
    JMMenuActionsViewAction_Schedule        = 1 << 16,
    JMMenuActionsViewAction_Share           = 1 << 17,
    JMMenuActionsViewAction_Bookmarks       = 1 << 18,
    JMMenuActionsViewAction_ShowExternalDisplay = 1 << 19,
    JMMenuActionsViewAction_HideExternalDisplay = 1 << 20,
    JMMenuActionsViewAction_ShowReportChartTypes = 1 << 21
};

@interface JMMenuAction : NSObject
@property (nonatomic, strong, readonly) NSString *actionTitle;
@property (nonatomic, strong, readonly) NSString *actionImageName;
@property (nonatomic, assign) JMMenuActionsViewAction menuAction;
@property (nonatomic, assign) BOOL actionEnabled;
@property (nonatomic, assign) BOOL actionAvailable;
- (instancetype)initWithAction:(JMMenuActionsViewAction)action available:(BOOL)available enabled:(BOOL)enabled;
+ (instancetype)menuActionWithAction:(JMMenuActionsViewAction)action available:(BOOL)available enabled:(BOOL)enabled;
@end
