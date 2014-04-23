//
//  JMResourcesDataManager.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/25/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMResourcesDataManager.h"
#import "JMResourceClientHolder.h"
#import <Objection-iOS/Objection.h>

static NSString * const kJMOffsetKey = @"offset";
static NSString * const kJMTotalCount = @"totalCount";
static NSInteger const kJMLimit = 15;

@interface JMResourcesDataManager () <JMResourceClientHolder>
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, weak) id <JSRequestDelegate> delegate;
@end

@implementation JMResourcesDataManager
objection_requires(@"resourceClient", @"constants")

@synthesize resourceClient = _resourceClient;

#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        self.activeResources = JMActiveResourcesAll;
        self.data = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)setResources:(NSArray *)resources
{
    [self.data setObject:[resources mutableCopy] forKey:@(self.activeResources)];
}

- (NSArray *)resources
{
    return [self.data objectForKey:@(self.activeResources)];
}

- (void)addResources:(NSArray *)resources
{
    NSMutableArray *res = [self.data objectForKey:@(self.activeResources)];
    if (!res) {
        res = [NSMutableArray array];
        [self.data setObject:res forKey:@(self.activeResources)];
    }
    [res addObjectsFromArray:resources];
}

- (void)loadResources:(NSString *)folderUri query:(NSString *)query delegate:(id <JSRequestDelegate>)delegate
{

    __weak JMResourcesDataManager *weakSelf = self;

    JSRequestFinishedBlock finishedBlock = ^(JSOperationResult *result) {
        if (result.isError || result.error) return;

//        [weakSelf.data setObject:<#(id)anObject#> forKey:<#(id <NSCopying>)aKey#>];
    };

//    [self.resourceClient resourceLookups:folderUri query:query types:self.activeResourceTypes recursive:NO offset:<#(NSInteger)offset#> limit:<#(NSInteger)limit#> usingBlock:^(JSRequest *request) {
//        request.finishedBlock = finishedBlock;
//        request.delegate = delegate;
//    };
}

#pragma mark - Private

- (NSArray *)activeResourceTypes
{
    switch (self.activeResources) {
        case JMActiveResourcesReports:
            return @[self.constants.WS_TYPE_REPORT_UNIT];

        case JMActiveResourcesDashboards:
            return @[self.constants.WS_TYPE_DASHBOARD];

        case JMActiveResourcesAllButFolders:
            return @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD];

        case JMActiveResourcesAll:
        default:
            return nil;
    }
}

@end
