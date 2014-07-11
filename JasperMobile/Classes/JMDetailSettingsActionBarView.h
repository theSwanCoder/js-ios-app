//
//  JMDetailSettingsActionBarView.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/11/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JMDetailSettingsActionBarView;

@protocol JMDetailSettingsActionBarViewDelegate <NSObject>
@required
- (void) cancelButtonTappedInActionView:(JMDetailSettingsActionBarView *)actionView;
- (void) saveButtonTappedInActionView:(JMDetailSettingsActionBarView *)actionView;
@end

@interface JMDetailSettingsActionBarView : UIView
@property (nonatomic, weak) id <JMDetailSettingsActionBarViewDelegate> delegate;
@end
