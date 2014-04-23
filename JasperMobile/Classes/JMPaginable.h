//
//  JMPaginable.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 4/1/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JMPaginable <NSObject>
@required
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger totalCount;
- (BOOL)hasNextPage;
- (void)loadNextPage;

@end
