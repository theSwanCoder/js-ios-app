//
//  JMResourcesListLoader.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/11/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMResourceClientHolder.h"
#import "JMPagination.h"

@class JMResourcesListLoader;
@protocol JMResourcesListLoaderDelegate <NSObject>
@required
- (void)resourceListDidStartLoading:(JMResourcesListLoader *)listLoader;
- (void)resourceListDidLoaded:(JMResourcesListLoader *)listLoader withError:(NSError *)error;

@end

@interface JMResourcesListLoader : NSObject <JMResourceClientHolder, JMPagination>

@property (nonatomic, weak) id <JMResourcesListLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL isLoadingNow;

// Params for loading request.
@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, strong) NSArray *resourcesTypes;
@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, strong) NSString *sortBy;
@property (nonatomic, assign) BOOL loadRecursively;
@property (nonatomic, strong) NSString *filterByTag;


- (void)takeParametersFromNotificationUserInfo: (NSDictionary *)userInfo;

@end
