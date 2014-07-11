//
//  JMDetailSettings.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/11/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailSettings.h"
#import "JMDetailSettingsItem.h"
#import "JMLocalization.h"
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import <Objection-iOS/Objection.h>


@interface JMDetailSettings ()

@property (nonatomic, readwrite, strong) NSArray *itemsArray;

@end


@implementation JMDetailSettings

- (NSArray *)itemsArray{
    if (!_itemsArray) {
        [self createItemsArray];
    }
    return _itemsArray;
}

- (void)createItemsArray
{
    NSMutableArray *itemsArray = [NSMutableArray array];
    JSObjectionInjector *injector = [JSObjection defaultInjector];
    // Inject resource and report clients
    JSRESTResource *resourceClient = [injector getObject:[JSRESTResource class]];
    JSRESTReport *reportClient = [injector getObject:[JSRESTReport class]];

    NSArray *itemsSourceArray =
    @[@{@"title" : JMCustomLocalizedString(@"detail.settings.item.connection.timeout", nil), @"settingsKey" : kJMDefaultRequestTimeout, @"value" : @(resourceClient.timeoutInterval)},
      @{@"title" : JMCustomLocalizedString(@"detail.settings.item.data.read.timeout", nil),  @"settingsKey" : kJMReportRequestTimeout,  @"value" : @(reportClient.timeoutInterval)}];
    
    for (NSDictionary *itemData in itemsSourceArray) {
        JMDetailSettingsItem *item = [[JMDetailSettingsItem alloc] init];
        item.titleString = [itemData objectForKey:@"title"];
        item.keyString = [itemData objectForKey:@"settingsKey"];
        item.valueString = [NSString stringWithFormat:@"%.0f", [[itemData objectForKey:@"value"] floatValue]];
        [itemsArray addObject:item];
    }
    
    self.itemsArray = itemsArray;
}

- (void) saveSettings
{
    [self.itemsArray makeObjectsPerformSelector:@selector(saveSettings)];

    JSObjectionInjector *injector = [JSObjection defaultInjector];
    // Inject resource and report clients
    JSRESTResource *resourceClient = [injector getObject:[JSRESTResource class]];
    JSRESTReport *reportClient = [injector getObject:[JSRESTReport class]];

    resourceClient.timeoutInterval = [[[self.itemsArray objectAtIndex:0] valueString] floatValue];
    reportClient.timeoutInterval   = [[[self.itemsArray objectAtIndex:1] valueString] floatValue];
}

@end
