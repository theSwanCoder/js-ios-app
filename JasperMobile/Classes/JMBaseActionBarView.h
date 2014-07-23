//
//  JMBaseActionBarView.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/17/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JMBaseActionBarView;

typedef NS_ENUM(NSInteger, JMBaseActionBarViewAction) {
    JMBaseActionBarViewAction_Refresh = 0,
    JMBaseActionBarViewAction_Share,
    JMBaseActionBarViewAction_Edit,
    JMBaseActionBarViewAction_Delete,
    JMBaseActionBarViewAction_Save,
    JMBaseActionBarViewAction_Cancel,
    JMBaseActionBarViewAction_Run
};

@protocol JMBaseActionBarViewDelegate <NSObject>
@required
- (void) actionView:(JMBaseActionBarView *)actionView didSelectAction:(JMBaseActionBarViewAction)action;
@end


@interface JMBaseActionBarView : UIView {
    IBOutletCollection(UIButton) NSArray *_actionBarButtons;
}

@property (nonatomic, weak) id <JMBaseActionBarViewDelegate> delegate;
@property (nonatomic, assign) JMBaseActionBarViewAction disabledAction;

@end
