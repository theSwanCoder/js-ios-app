//
//  JMLibraryListLoader.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/12/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMLibraryListLoader.h"

@implementation JMLibraryListLoader

- (id)init
{
    self = [super init];
    if (self) {
        self.resourcesType = JMResourcesListLoaderObjectType_LibraryAll;
        self.sortBy = JMResourcesListLoaderSortBy_Name;
        self.loadRecursively = YES;
    }
    return self;
}

@end
