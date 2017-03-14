/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import "JMPopupView.h"
#import "JMResourcesListLoader.h"

@interface JMListOptionsPopupView : JMPopupView

@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, assign) JMResourcesListLoaderOptionType optionType;
@property(nonatomic, strong) NSString *titleString;

- (id)initWithDelegate:(id<JMPopupViewDelegate>)delegate type:(JMPopupViewType)type options:(NSArray <JMResourceLoaderOption *>*)options;
@end
