//
//  JMSearchBar.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/12/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMSearchBar;

@protocol JMSearchBarDelegate <NSObject>
@optional

- (void)searchBarSearchButtonClicked:(JMSearchBar *)searchBar;
- (void)searchBarClearButtonClicked:(JMSearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(JMSearchBar *) searchBar;
- (void)searchBarDidChangeText:(JMSearchBar *) searchBar;

@end

@interface JMSearchBar : UIView
@property (nonatomic, weak) id <JMSearchBarDelegate> delegate;

@property (nonatomic, readwrite) UIColor *textColor;
@property (nonatomic, readwrite) NSString *text;
@property (nonatomic, readwrite) NSString *placeholder;

@end
