//
//  JSAppUpdater.m
//  JasperMobile
//

#import "SSKeychain.h"
#import "JSAppUpdater.h"
#import "JSProfile+Helpers.h"
#import "JasperMobileAppDelegate.h"

// Contains version:method structure. Method updates specific part of application for specific app version
static NSDictionary *versionsToUpdate = nil;

// NSUserDefaults keys
static NSString * const keyJaspersoftMobileUpdatedVersions = @"jaspersoft.mobile.updated.versions";
static NSString * const keyJaspersoftMobileCurrentVersion = @"jaspersoft.mobile.current.version";
static NSString * const keyJaspersoftServerCount = @"jaspersoft.server.count";
static NSString * const keyJaspersoftServerUsername = @"jaspersoft.server.username.%d";
static NSString * const keyJaspersoftServerOrganization = @"jaspersoft.server.organization.%d";
static NSString * const keyJaspersoftServerBaseUrl = @"jaspersoft.server.baseUrl.%d";
static NSString * const keyJaspersoftServerPassword = @"jaspersoft.server.password.%d";

// Key for app version
static NSString * const keyApplicaitonVersion = @"CFBundleShortVersionString";

@implementation JSAppUpdater

// Fill migrations with update methods for different versions
+ (void)initialize {
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];    
    
    // Add update methods
    [temp setObject:NSStringFromSelector(@selector(update_1_2)) forKey:[NSNumber numberWithDouble:1.2]];
    
    versionsToUpdate = temp;
}

+ (NSString *)appVersion {
    return [[NSBundle mainBundle].infoDictionary objectForKey:keyApplicaitonVersion];
}

+ (void)update {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *appVersion = [NSNumber numberWithDouble:[[self appVersion] doubleValue]];
    
    if ([appVersion doubleValue] == [prefs doubleForKey:keyJaspersoftMobileCurrentVersion]) {
        return;
    }
    
    // Already updated versions
    NSMutableArray *updatedVersions = [[NSMutableArray alloc] initWithArray:
                                           [prefs arrayForKey:keyJaspersoftMobileUpdatedVersions] ?: [NSArray array]];
    for (NSNumber *version in versionsToUpdate.allKeys) {        
        if ([appVersion compare:version] >= 0 && ![updatedVersions containsObject:version]) {
            [self performSelector:NSSelectorFromString([versionsToUpdate objectForKey:version]) withObject:self];
            [updatedVersions addObject:version];
        }
    }
    
    [prefs setObject:appVersion forKey:keyJaspersoftMobileCurrentVersion];
    [prefs setObject:updatedVersions forKey:keyJaspersoftMobileUpdatedVersions];
    [prefs synchronize];
}

+ (void)update_1_2 {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger count = [prefs integerForKey:keyJaspersoftServerCount];
    
    for (int i = 0; i < count; i++) {
        NSString *serverUrl = [prefs objectForKey:[NSString stringWithFormat:keyJaspersoftServerBaseUrl, i]];
        NSString *username = [prefs objectForKey:[NSString stringWithFormat:keyJaspersoftServerUsername, i]];
        NSString *organization = [prefs objectForKey:[NSString stringWithFormat:keyJaspersoftServerOrganization, i]];
        NSString *password = [prefs objectForKey:[NSString stringWithFormat:keyJaspersoftServerPassword, i]];
        NSString *profileID = [JSProfile profileIDByServerURL:serverUrl username:username organization:organization];
        [SSKeychain setPassword:password forService:[JasperMobileAppDelegate keychainServiceName] account:profileID];
        [prefs removeObjectForKey:[NSString stringWithFormat:keyJaspersoftServerPassword, count]];
    }
    
    [prefs synchronize];
}

@end
