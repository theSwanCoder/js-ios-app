/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMServerOptionManager.h"
#import "JMServerProfile+Helpers.h"
#import "JMCoreDataManager.h"
#import "JMSessionManager.h"
#import "JMLocalization.h"

NSString * const kJMBooleanCellIdentifier = @"BooleanCell";
NSString * const kJMTextCellIdentifier = @"TextEditCell";

NSString *const JMCacheReportsOptionDidChangeNotification = @"JMCacheReportsOptionDidChangeNotification";

@interface JMServerOptionManager ()
@property (nonatomic, readwrite) NSDictionary <NSNumber *, JMServerOption *>*availableOptions;
@end

@implementation JMServerOptionManager
- (id)initWithServerProfile:(JMServerProfile *)serverProfile
{
    self = [super init];
    if (self) {
        self.isExistingServerProfile = serverProfile != nil;
        if (serverProfile) {
            self.serverProfile = serverProfile;
        } else {
            self.serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile"
                                                                                   inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
        }
    }
    return self;
}

- (void)saveChanges
{
    BOOL isActiveServerProfile = [self.serverProfile isActiveServerProfile];
    
    self.serverProfile.alias        = [self.availableOptions[@(JMServerOptionTypeAlias)] optionValue];
    self.serverProfile.serverUrl    = [self.availableOptions[@(JMServerOptionTypeURL)] optionValue];
    self.serverProfile.organization = [self.availableOptions[@(JMServerOptionTypeOrganization)] optionValue];
    self.serverProfile.askPassword  = [self.availableOptions[@(JMServerOptionTypeAskPassword)] optionValue];
    self.serverProfile.keepSession  = [self.availableOptions[@(JMServerOptionTypeKeepSession)] optionValue];
#ifndef  __RELEASE__
    self.serverProfile.useVisualize = [self.availableOptions[@(JMServerOptionTypeUseVisualize)] optionValue];
    BOOL cacheReportsNewValue = ((NSNumber *)[self.availableOptions[@(JMServerOptionTypeCacheReports)] optionValue]).boolValue;
    BOOL cacheReportsCurrentValue = self.serverProfile.cacheReports.boolValue;
    self.serverProfile.cacheReports = @(cacheReportsNewValue);
    if (cacheReportsCurrentValue != cacheReportsNewValue) {
        // POST notification
//        [[NSNotificationCenter defaultCenter] postNotificationName:JMCacheReportsOptionDidChangeNotification
//                                                            object:self.serverProfile];
    }
#endif
    
    if ([[JMCoreDataManager sharedInstance].managedObjectContext hasChanges]) {
        NSError *error = nil;
        [[JMCoreDataManager sharedInstance] save:&error];
        
        if (!error) {
            if (isActiveServerProfile) {
                // update current active server profile
                [[JMSessionManager sharedManager] updateSessionServerProfileWith:self.serverProfile];
            }
        }
    }
}

- (BOOL)isValidData
{
    BOOL isValidData = YES;
    JMServerOption *serverOption = self.availableOptions[@(JMServerOptionTypeAlias)];
    if (serverOption.optionValue && [[serverOption.optionValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        // Check if alias is unique
        if (!self.isExistingServerProfile && ![self.serverProfile isValidNameForServerProfile:serverOption.optionValue]) {
            isValidData = NO;
            serverOption.errorString = JMLocalizedString(@"servers_name_errmsg_exists");
        }
    } else {
        isValidData = NO;
        serverOption.errorString = JMLocalizedString(@"servers_name_errmsg_empty");
    }
    
    serverOption = self.availableOptions[@(JMServerOptionTypeURL)];
    if (serverOption.optionValue && [serverOption.optionValue length]) {
        NSURL *url = [NSURL URLWithString:serverOption.optionValue];
        if (!url || !url.scheme || !url.host) {
            isValidData = NO;
            serverOption.errorString = JMLocalizedString(@"servers_url_errmsg");;
        }
    } else {
        isValidData = NO;
        serverOption.errorString = JMLocalizedString(@"servers_url_errmsg");
    }
    
    return isValidData;
}

- (NSString *)urlSchemeForServerProfile
{
    if ([self isValidData]) {
        NSString *urlString = [self.availableOptions[@(JMServerOptionTypeURL)] optionValue];
        NSString *scheme = [NSURL URLWithString:urlString].scheme;
        return scheme;
    }
    return nil;
}


- (void)discardChanges
{
    [[JMCoreDataManager sharedInstance].managedObjectContext reset];
}

- (NSDictionary  *)availableOptions{
    if (!_availableOptions) {
        _availableOptions = [self createAvailableOptions];
    }
    return _availableOptions;
}

- (NSDictionary  *)createAvailableOptions
{
    NSDictionary *availableOptions = @{
            @(JMServerOptionTypeAlias) : [JMServerOption optionWithTitle:[self localizedString:@"servers_name_label" mandatory:YES]
                                                             optionValue:self.serverProfile.alias ? : @""
                                                          cellIdentifier:kJMTextCellIdentifier
                                                                editable:YES],
            @(JMServerOptionTypeURL) : [JMServerOption optionWithTitle:[self localizedString:@"servers_url_label" mandatory:YES]
                                                             optionValue:self.serverProfile.serverUrl ? : @""
                                                          cellIdentifier:kJMTextCellIdentifier
                                                                editable:self.editable],
            @(JMServerOptionTypeOrganization) : [JMServerOption optionWithTitle:[self localizedString:@"servers_orgid_label" mandatory:NO]
                                                             optionValue:self.serverProfile.organization ? : @""
                                                          cellIdentifier:kJMTextCellIdentifier
                                                                editable:self.editable],
            @(JMServerOptionTypeAskPassword) : [JMServerOption optionWithTitle:[self localizedString:@"servers_askpassword_label" mandatory:NO]
                                                             optionValue:self.serverProfile.askPassword ? : @(NO)
                                                          cellIdentifier:kJMBooleanCellIdentifier
                                                                editable:YES],
            @(JMServerOptionTypeKeepSession) : [JMServerOption optionWithTitle:[self localizedString:@"servers_keepSession_label" mandatory:NO]
                                                             optionValue:self.serverProfile.keepSession  ? : @(NO)
                                                          cellIdentifier:kJMBooleanCellIdentifier
                                                                editable:YES],
            @(JMServerOptionTypeUseVisualize) : [JMServerOption optionWithTitle:[self localizedString:@"servers_useVisualize_label" mandatory:NO]
                                                             optionValue:self.serverProfile.useVisualize  ? : @(NO)
                                                          cellIdentifier:kJMBooleanCellIdentifier
                                                                editable:YES],
            @(JMServerOptionTypeCacheReports) : [JMServerOption optionWithTitle:[self localizedString:@"servers_cacheReport_label" mandatory:NO]
                                                             optionValue:self.serverProfile.cacheReports  ? : @(NO)
                                                          cellIdentifier:kJMBooleanCellIdentifier
                                                                editable:YES],
    };

    return availableOptions;
}

- (NSString *)localizedString:(NSString *)key mandatory:(BOOL)mandatory
{
    if (mandatory) {
       return [NSString stringWithFormat:@"* %@",JMLocalizedString(key)];
    }
    return JMLocalizedString(key);
}

@end
