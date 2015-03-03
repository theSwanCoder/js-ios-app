/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */

//
//  JMPopupView.m
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.9
 */


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JMPopupViewType) {
    JMPopupViewType_ContentViewOnly = 0,
    JMPopupViewType_OkCancelButtons
};


#define kJMPopupViewContentMaxHeight        [JMUtils isIphone] ? 260.f : 360.f
#define kJMPopupViewDefaultWidth            [JMUtils isIphone] ? 260.f : 360.f
#define kJMPopupViewButtonsHeight           [JMUtils isIphone] ? 35.f  : 44.f

@class JMPopupView;
@protocol JMPopupViewDelegate <NSObject>

@optional
- (void)popupViewWillDismissed:(JMPopupView *)popup;
- (void)popupViewWillShow:(JMPopupView *)popup;

- (void)popupViewDidDismissed:(JMPopupView *)popup;
- (void)popupViewDidShow:(JMPopupView *)popup;

- (void)popupViewDidApplied:(JMPopupView *)popup;
- (void)popupViewDidCanceled:(JMPopupView *)popup;

- (void)popupViewValueDidChanged:(JMPopupView *)popup;

@end

@interface JMPopupView : UIView{
    UIView* _backGroundView;
    UIView* _contentView;
}

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, readonly) JMPopupViewType type;
@property (nonatomic, weak) id <JMPopupViewDelegate> delegate;
@property (nonatomic, assign) BOOL isDissmissWithTapOutOfButton;

- (id) initWithDelegate:(id <JMPopupViewDelegate>)delegate type:(JMPopupViewType)type;

- (void)show;
- (void)showFromPoint:(CGPoint)point onView:(UIView*)view;

- (void)dismiss;
- (void)dismiss:(BOOL)animated;
+ (void)dismissAllVisiblePopups:(BOOL)animated;

+ (JMPopupView *)displayedPopupViewForClass:(Class)someClass;
@end
