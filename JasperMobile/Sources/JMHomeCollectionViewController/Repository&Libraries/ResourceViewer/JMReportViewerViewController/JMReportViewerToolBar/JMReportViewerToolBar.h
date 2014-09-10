//
//  JMReportViewerToolBar.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/17/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JMReportViewerToolBarDelegate <NSObject>

@optional
- (void) pageDidChangedOnToolbar;

@end

@interface JMReportViewerToolBar : UIToolbar

@property (nonatomic, weak) id <JMReportViewerToolBarDelegate> toolbarDelegate;

@property (nonatomic, assign) NSInteger countOfPages;
@property (nonatomic, assign) NSInteger currentPage;

@end
