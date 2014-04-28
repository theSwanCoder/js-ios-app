//
// Created by Vlad Zavadskii on 4/24/14.
// Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JMPaginationData : NSObject

@property (nonatomic, weak) NSArray *resources;
@property (nonatomic, assign) NSInteger totalCount;
// Indicates if resources type was changed for this request
@property (nonatomic, assign) BOOL isNewResourcesType;
@property (nonatomic, assign) BOOL hasNextPage;

@end