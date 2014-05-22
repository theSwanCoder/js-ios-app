//
//  JMPagination.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/20/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JMPagination <NSObject>
@required
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger totalCount;

@optional
- (void)loadNextPage;
- (BOOL)hasNextPage;

@end
