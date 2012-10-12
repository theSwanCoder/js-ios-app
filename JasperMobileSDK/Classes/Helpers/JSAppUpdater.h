//
//  JSAppUpdater.h
//  JasperMobile
//

#import <Foundation/Foundation.h>

// This class updates automatically specific part of application if application
// was updated from App Store. Idea is to store version of application inside 
// NSUserDefaults, and if that version was changed update app automatically.
// Example: if old app was 1.0 version, and there was some major changes (i.e. 
// changed database structure), after updating to 1.2 updates 1.1 and 1.2 will
// be performed (which adapts and move data from old to new database structure)
@interface JSAppUpdater : NSObject

// Updates app
+ (void)update;

@end
