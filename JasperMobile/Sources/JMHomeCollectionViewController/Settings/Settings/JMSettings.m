//
//  JMSettings.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/11/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSettings.h"
#import "JMSettingsItem.h"
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JMReportClientHolder.h"
#import "JMResourceClientHolder.h"
#import "JMServerProfile+Helpers.h"

static NSString * const kJMTextCellIdentifier = @"TextCellIdentifier";
static NSString * const kJMServerCellIdentifier = @"ServerCellIdentifier";


@interface JMSettings () <JMReportClientHolder, JMResourceClientHolder>
@property (nonatomic, readwrite, strong) NSArray *itemsArray;

@end


@implementation JMSettings
objection_requires(@"resourceClient", @"reportClient")

@synthesize resourceClient = _resourceClient;
@synthesize reportClient = _reportClient;

- (id)init{
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
        [self createItemsArray];
    }
    return self;
}

- (void)createItemsArray
{
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    NSString *serverString = activeServerProfile ? activeServerProfile.alias : @"";
    
    NSMutableArray *itemsArray = [NSMutableArray array];
    NSArray *itemsSourceArray =
    @[@{@"title" : JMCustomLocalizedString(@"detail.settings.item.server", nil), @"value" : serverString, @"cellIdentifier" : kJMServerCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"detail.settings.item.connection.timeout", nil), @"value" : @(self.resourceClient.timeoutInterval), @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"detail.settings.item.data.read.timeout", nil), @"value" : @(self.reportClient.timeoutInterval), @"cellIdentifier" : kJMTextCellIdentifier}];
    
    for (NSDictionary *itemData in itemsSourceArray) {
        JMSettingsItem *item = [[JMSettingsItem alloc] init];
        item.titleString = [itemData objectForKey:@"title"];
        if ([[itemData objectForKey:@"value"] isKindOfClass:[NSNumber class]]) {
            item.valueSettings = [NSString stringWithFormat:@"%.0f", [[itemData objectForKey:@"value"] doubleValue]];
        } else {
            item.valueSettings = [itemData objectForKey:@"value"];
        }
        item.cellIdentifier = [itemData objectForKey:@"cellIdentifier"];
        [itemsArray addObject:item];
    }
    
    self.itemsArray = itemsArray;
}

- (void) saveSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[self.itemsArray objectAtIndex:1] valueSettings] forKey:kJMDefaultRequestTimeout];
    [defaults setObject:[[self.itemsArray objectAtIndex:2] valueSettings] forKey:kJMReportRequestTimeout];
    [defaults synchronize];
    
    self.resourceClient.timeoutInterval = [[[self.itemsArray objectAtIndex:1] valueSettings] doubleValue];
    self.reportClient.timeoutInterval   = [[[self.itemsArray objectAtIndex:2] valueSettings] doubleValue];
}

@end
