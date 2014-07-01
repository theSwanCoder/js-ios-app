//
//  JMSearchable.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/19/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JMHeaderBarAdditions <NSObject>
@optional
- (void)setBarTitle:(__weak UILabel *)label;
- (void)searchWithQuery:(NSString *)query;
- (void)didClearSearch;

@end
