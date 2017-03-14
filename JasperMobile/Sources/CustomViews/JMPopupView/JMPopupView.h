/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JMPopupViewType) {
    JMPopupViewType_ContentViewOnly = 0,
    JMPopupViewType_ContentWithMessage,
    JMPopupViewType_OkCancelButtons
};


#define kJMPopupViewContentMaxHeight        ([JMUtils isCompactHeight] ? 260.f : 360.f)
#define kJMPopupViewDefaultWidth            ([JMUtils isCompactWidth]  ? 260.f : 360.f)
#define kJMPopupViewButtonsHeight           ([JMUtils isCompactHeight] ? 35.f  : 44.f)

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
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) BOOL isDissmissWithTapOutOfButton;

- (instancetype)initWithDelegate:(id <JMPopupViewDelegate>)delegate type:(JMPopupViewType)type;
- (instancetype)initWithMessage:(NSString *)message delegate:(id<JMPopupViewDelegate>)delegate;

- (void) show;

- (void) showFromPoint:(CGPoint)point onView:(UIView*)view;

- (IBAction) dismissByValueChanged;

- (void) dismiss;

- (void) dismiss:(BOOL)animated;

+ (void)dismissAllVisiblePopups:(BOOL)animated;

+ (JMPopupView *)displayedPopupViewForClass:(Class)someClass;
@end
