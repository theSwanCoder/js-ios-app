//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+ExportedResource.h"
#import "JMBaseUITestCase+SideMenu.h"


@implementation JMBaseUITestCase (ExportedResource)

- (void)removeExportedResourceWithAccessibilityId:(NSString *)accessibilityId
{

}

- (void)verifyExistExportedResourceWithAccessibilityId:(NSString *)accessibilityId
{
    [self openSavedItemsSection];
}

@end