/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


#import "JMFilterOptionsPopupView.h"

@interface JMFilterOptionsPopupView ()
@property (nonatomic, weak) IBOutlet UILabel *resourceTypeTitleLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *resourceTypeSegmentedControl;

@end


@implementation JMFilterOptionsPopupView

- (id)initWithDelegate:(id<JMPopupViewDelegate>)delegate type:(JMPopupViewType)type{
    self = [super initWithDelegate:delegate type:type];
    if (self) {
        UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];

        self.resourceTypeTitleLabel.text = JMCustomLocalizedString(@"master.resources.title", nil);
        [self.resourceTypeSegmentedControl setTitle:JMCustomLocalizedString(@"master.resources.type.all", nil) forSegmentAtIndex:0];
        [self.resourceTypeSegmentedControl setTitle:JMCustomLocalizedString(@"master.resources.type.reportUnit", nil) forSegmentAtIndex:1];
        [self.resourceTypeSegmentedControl setTitle:JMCustomLocalizedString(@"master.resources.type.dashboard", nil) forSegmentAtIndex:2];

        self.resourceTypeSegmentedControl.apportionsSegmentWidthsByContent = YES;
        
        self.contentView = nibView;
    }
    
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint controlPoint = [self convertPoint:point toView:self.resourceTypeSegmentedControl];
    if (CGRectContainsPoint(self.resourceTypeSegmentedControl.bounds, controlPoint)) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1];
    }
    return [super hitTest:point withEvent:event];
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
