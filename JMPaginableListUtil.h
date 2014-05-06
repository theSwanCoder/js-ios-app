//
//  JMPaginableListUtil.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/5/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JMPaginableList
@required
@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, assign) NSInteger paginationTreshoald;

@end

@protocol JMPaginableListUtil <NSObject>

@property (nonatomic, weak) id <JMPaginableList> paginableList;

- (BOOL)isPaginationCell:(NSIndexPath *)indexPath;
- (void)loadNextPage:(NSIndexPath *)indexPath;
- (NSInteger)numberOfItems;
- (void)scrollToFirstVisibleResources;

@end
