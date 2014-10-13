//
//  JMFilterOptionsPopupView.m
//  Tibco JasperMobile
//
//  Created by Oleksii Gubariev on 10/13/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMFilterOptionsPopupView.h"

@interface JMFilterOptionsPopupView ()
@property (nonatomic, weak) IBOutlet UILabel *resourceTypeTitleLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *resourceTypeSegmentedControl;
@property (nonatomic, weak) IBOutlet UILabel *tagTitleLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *tagSegmentedControl;

@end


@implementation JMFilterOptionsPopupView

- (id)initWithDelegate:(id<JMPopupViewDelegate>)delegate{
    self = [super initWithDelegate:delegate];
    if (self) {
        UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];

        self.resourceTypeTitleLabel.text = JMCustomLocalizedString(@"master.resources.title", nil);
        [self.resourceTypeSegmentedControl setTitle:JMCustomLocalizedString(@"master.resources.type.all", nil) forSegmentAtIndex:0];
        [self.resourceTypeSegmentedControl setTitle:JMCustomLocalizedString(@"master.resources.type.reportUnit", nil) forSegmentAtIndex:1];
        [self.resourceTypeSegmentedControl setTitle:JMCustomLocalizedString(@"master.resources.type.dashboard", nil) forSegmentAtIndex:2];

        self.resourceTypeSegmentedControl.apportionsSegmentWidthsByContent = YES;
        
        self.tagTitleLabel.text = JMCustomLocalizedString(@"master.filterbytag.title", nil);
        [self.tagSegmentedControl setTitle:JMCustomLocalizedString(@"master.filterbytag.type.none", nil) forSegmentAtIndex:0];
        [self.tagSegmentedControl setTitle:JMCustomLocalizedString(@"master.filterbytag.type.favorites", nil) forSegmentAtIndex:1];
        
        self.contentView = nibView;
    }
    
    return self;
}

- (void)setFilterBy:(JMResourcesListLoaderFilterBy)filterBy
{
    self.tagSegmentedControl.selectedSegmentIndex = filterBy;
}

- (JMResourcesListLoaderFilterBy)filterBy
{
    return self.tagSegmentedControl.selectedSegmentIndex;
}

- (void)setObjectType:(JMResourcesListLoaderObjectType)objectType
{
    switch (objectType) {
        case JMResourcesListLoaderObjectType_Reports:
            self.resourceTypeSegmentedControl.selectedSegmentIndex = 1;
            break;
        case JMResourcesListLoaderObjectType_Dashboards:
            self.resourceTypeSegmentedControl.selectedSegmentIndex = 2;
            break;
        default:
            self.resourceTypeSegmentedControl.selectedSegmentIndex = 0;
            break;
    }
}

- (JMResourcesListLoaderObjectType)objectType
{
    if (self.resourceTypeSegmentedControl.selectedSegmentIndex) {
        return 1 << self.resourceTypeSegmentedControl.selectedSegmentIndex;
    } else {
        return JMResourcesListLoaderObjectType_LibraryAll;
    }
}
@end
