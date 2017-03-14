/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.6
 */

#import <UIKit/UIKit.h>
#import "JMEditabledViewController.h"
#import "JMSaveResourceSection.h"
#import "JMResource.h"

@protocol JMSaveResourceViewControllerDelegate <NSObject>

@required
- (void)resourceDidSavedSuccessfully;

@end

@interface JMSaveResourceViewController : JMEditabledViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <JMSaveResourceViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveResourceButton;

@property (nonatomic, strong) NSArray *availableFormats;
@property (nonatomic, strong) NSString *selectedFormat;

@property (nonatomic, strong) NSString *resourceName;
@property (nonatomic, strong) NSString *errorString;
@property (nonatomic, assign) JMResourceType resourceType;

@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, copy) void(^sessionExpiredBlock)(void);
    
- (void)addObservers NS_REQUIRES_SUPER;
    
- (void)setupSections NS_REQUIRES_SUPER;

- (void) saveResource NS_REQUIRES_SUPER;

- (void)verifyExportDataWithCompletion:(void(^)(BOOL success))completion NS_REQUIRES_SUPER;

- (JMSaveResourceSection *)sectionForType:(JMSaveResourceSectionType)sectionType;

- (void) reloadSectionForType:(JMSaveResourceSectionType)sectionType;

@end
