//
//  JSProfile+Helpers.h
//  JasperMobile
//

#import <jaspersoft-sdk/JaspersoftSDK.h>

@interface JSProfile (Helpers)

@property (nonatomic, retain) NSString *tempPassword;
@property (nonatomic, retain) NSNumber *alwaysAskPassword;

+ (NSString *)profileIDByServerURL:(NSString *)url username:(NSString *)username organization:(NSString *)organization;
- (BOOL)isEqualToProfile:(JSProfile *)profile;
- (BOOL)isEqualToProfileByServerURL:(NSString *)url username:(NSString *)username organization:(NSString *)organization;
- (NSString *)profileID;

@end
