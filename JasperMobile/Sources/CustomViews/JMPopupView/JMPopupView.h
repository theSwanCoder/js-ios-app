//
//  JMPopupView.h
//  BetterInterviewsAdmin
//
//  Created by Gubariev, Oleksii on 4/7/14.
//  Copyright (c) 2014 SphereConsultingInc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMPopupView;
@protocol JMPopupViewDelegate <NSObject>

@optional
- (void)popupViewWillDismissed:(JMPopupView *)popup;
- (void)popupViewWillShow:(JMPopupView *)popup;

- (void)popupViewDidDismissed:(JMPopupView *)popup;
- (void)popupViewDidShow:(JMPopupView *)popup;

- (void)popupViewDidApplied:(JMPopupView *)popup;
- (void)popupViewDidCanceled:(JMPopupView *)popup;
@end

@interface JMPopupView : UIView{
    UIView* _backGroundView;
    UIView* _contentView;
}

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, weak) id <JMPopupViewDelegate> delegate;


- (id) initWithDelegate:(id <JMPopupViewDelegate>)delegate;

- (void) show;

- (void) showFromPoint:(CGPoint)point onView:(UIView*)view;

- (void) dismiss:(BOOL)animated;

@end
