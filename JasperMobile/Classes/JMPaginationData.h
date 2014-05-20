//
// Created by Vlad Zavadskii on 4/24/14.
// Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

@interface JMPaginationData : NSObject

@property (nonatomic, weak) JSResourceLookup *currentFolder;
@property (nonatomic, weak) NSArray *resources;
@property (nonatomic, strong) NSArray *resourcesTypes;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) BOOL loadRecursively;

@end