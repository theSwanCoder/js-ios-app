//
//  JMResourcesDataManager.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/25/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

typedef enum {
    JMActiveResourcesAll,
    // Includes all resources except folders
    JMActiveResourcesAllButFolders,
    JMActiveResourcesReports,
    JMActiveResourcesDashboards
} JMActiveResources;

// TODO: refactor
/**
 A helper class that contains fetched resources from JR server.
 This is a temp solution.
 */
@interface JMResourcesDataManager : NSObject

//@property (nonatomic, assign) JMActiveResources activeResources;
@property (nonatomic, assign) NSInteger firstVisibleResourceIndex;
@property (nonatomic, assign) JMActiveResources activeResources;

- (NSArray *)resources;
- (void)setResources:(NSArray *)resources;
- (void)addResources:(NSArray *)resources;

@end
