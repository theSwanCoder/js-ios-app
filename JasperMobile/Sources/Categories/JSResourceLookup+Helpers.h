//
//  JSResourceLookup+Helpers.h
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 3/16/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMDashboard.h"
#import "JMReport.h"


@interface JSResourceLookup (Helpers);

- (BOOL) isFolder;
- (BOOL) isReport;
- (BOOL) isSavedReport;
- (BOOL) isTempExportedReport;

- (BOOL) isDashboard;
- (BOOL) isNewDashboard;

- (NSString *) resourceViewerVCIdentifier;

- (NSString *) infoVCIdentifier;

- (JMReport *) reportModel;

- (JMDashboard *) dashboardModel;

- (NSString *)localizedResourceType;

@end
