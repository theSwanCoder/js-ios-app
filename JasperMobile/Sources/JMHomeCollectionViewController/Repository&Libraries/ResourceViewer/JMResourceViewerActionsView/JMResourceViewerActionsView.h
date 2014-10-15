//
//  JMResourceViewerActionsView.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JMResourceViewerAction) {
    JMResourceViewerAction_None = 0,
    JMResourceViewerAction_MakeFavorite = 1 << 0,
    JMResourceViewerAction_MakeUnFavorite = 1 << 1,
    JMResourceViewerAction_Refresh = 1 << 2,
    JMResourceViewerAction_Filter = 1 << 3,
    JMResourceViewerAction_Save = 1 << 4,
    JMResourceViewerAction_Delete = 1 << 5,
    JMResourceViewerAction_Rename = 1 << 6,
    JMResourceViewerAction_Info = 1 << 7
};

static inline JMResourceViewerAction JMResourceViewerActionFirst() { return JMResourceViewerAction_MakeFavorite; }
static inline JMResourceViewerAction JMResourceViewerActionLast() { return JMResourceViewerAction_Info; }

@class JMResourceViewerActionsView;

@protocol JMResourceViewerActionsViewDelegate <NSObject>
@required
- (void) actionsView:(JMResourceViewerActionsView *)view didSelectAction:(JMResourceViewerAction)action;

@end

@interface JMResourceViewerActionsView : UIView
@property (nonatomic, weak) id <JMResourceViewerActionsViewDelegate> delegate;
@property (nonatomic, assign) JMResourceViewerAction availableActions;

@end
