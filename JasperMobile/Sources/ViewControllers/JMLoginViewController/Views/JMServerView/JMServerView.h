//
//  JMServerView.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 11/12/15.
//  Copyright © 2015 TIBCO JasperMobile. All rights reserved.
//


@protocol JMServerViewDelegate;

@interface JMServerView : UIView
@property (nonatomic) NSString *title;
@property (nonatomic) NSInteger identifier;
@property (nonatomic, weak) NSObject<JMServerViewDelegate>* delegate;
@end

@protocol JMServerViewDelegate
@optional
- (void)serverViewDidSelect:(JMServerView *)serverView;
@end
