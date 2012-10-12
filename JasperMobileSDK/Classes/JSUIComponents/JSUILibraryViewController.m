//
//  JSUILibraryViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 02.10.12.
//
//

#import "JSUILibraryViewController.h"
#import "JasperMobileAppDelegate.h"
#import "UIAlertView+LocalizedAlert.h"

@implementation JSUILibraryViewController

- (void)clear {
    self.resources = nil;
    [self.tableView reloadData];
}

- (void)loadView {
    [super loadView];
}

- (void)updateTableContent {
    if (self.resourceClient == nil) {
        JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
        if (app.servers.count) {
            [app setProfile:[app.servers objectAtIndex:0]];
            [self updateTableContent];
            return;
        } else {
            [[UIAlertView localizedAlert:@"noservers.dialog.title"
                                 message:@"noservers.dialog.msg"
                                delegate:self
                       cancelButtonTitle:@"noservers.dialog.button.label"
                       otherButtonTitles:nil] show];
            return;
        }
    }
    
    if ([JSRESTBase isNetworkReachable] && resources == nil) {
		// load this view
        [JSUILoadingView showCancelableLoadingInView:self.view restClient:self.resourceClient delegate:self cancelBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [self.resourceClient resources:nil query:nil type:[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT recursive:YES limit:0 delegate:self];
    }
}

@end
