//
//  JMSortOptionsPopupView.m
//  BetterInterviewsAdmin
//
//  Created by Gubariev, Oleksii on 4/7/14.
//  Copyright (c) 2014 SphereConsultingInc. All rights reserved.
//

#import "JMSortOptionsPopupView.h"

@interface JMSortOptionsPopupView ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *sortBySegmentedControl;
@end



@implementation JMSortOptionsPopupView

- (id)initWithDelegate:(id<JMPopupViewDelegate>)delegate{
    self = [super initWithDelegate:delegate];
    if (self) {
        UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        self.titleLabel.text = JMCustomLocalizedString(@"master.sortby.title", nil);
        [self.sortBySegmentedControl setTitle:JMCustomLocalizedString(@"master.sortby.type.name", nil) forSegmentAtIndex:0];
        [self.sortBySegmentedControl setTitle:JMCustomLocalizedString(@"master.sortby.type.date", nil) forSegmentAtIndex:1];
        self.contentView = nibView;
    }

    return self;
}

- (void)setSortBy:(JMResourcesListLoaderSortBy)sortBy
{
    self.sortBySegmentedControl.selectedSegmentIndex = sortBy;
}

- (JMResourcesListLoaderSortBy)sortBy
{
    return self.sortBySegmentedControl.selectedSegmentIndex;
}

@end
