//
// Created by Vlad Zavadskii on 4/24/14.
// Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JMPagination.h"

@interface JMPaginationData : NSObject <JMPagination>

@property (nonatomic, weak) NSArray *resources;
@property (nonatomic, strong) JSResourceLookup *resourceLookup;
@property (nonatomic, strong) NSArray *resourcesTypes;
@property (nonatomic, assign) BOOL loadRecursively;

@end