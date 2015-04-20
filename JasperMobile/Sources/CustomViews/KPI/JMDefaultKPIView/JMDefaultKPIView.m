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


//
//  JMDefaultKPIView.m
//  TIBCO JasperMobile
//

#import "JMDefaultKPIView.h"
#import "JMBaseKPIModel.h"

@implementation JMDefaultKPIView

#pragma mark - Public API
- (void)setupViewWithKPIModel:(JMBaseKPIModel *)kpiModel
{
// clean kpiView
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSLog(@"has kpi: %@", kpiModel);

    // show kpi
    NSString *imageName = @"kpi_arrow_down";

    if (kpiModel.value > kpiModel.target) {
        imageName = @"kpi_arrow_up";
    }

    self.backgroundColor = [UIColor colorWithRed:24/255.0f green:27/255.0f blue:31/255.0f alpha:1.0];
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    CGRect arrowImageFrame = arrowImageView.frame;
    CGFloat arrowImageOriginX = 0.9 * CGRectGetWidth(self.frame) - CGRectGetWidth(arrowImageFrame);
    CGFloat arrowImageOriginY = 0.1 * CGRectGetHeight(self.frame);
    arrowImageFrame.origin = CGPointMake(arrowImageOriginX, arrowImageOriginY);
    arrowImageView.frame = arrowImageFrame;
    [self addSubview:arrowImageView];

    NSString *indicatorValue = [NSString stringWithFormat:@"%.0f %%", (kpiModel.value.doubleValue * 100) / kpiModel.target.doubleValue];
    CGFloat indicatorLabelOriginX = 0.1 * CGRectGetWidth(self.frame);
    CGFloat indicatorLabelOriginY = 0.3 * CGRectGetHeight(self.frame);
    CGFloat indicatorLabelWidth = 0.8 * CGRectGetWidth(self.frame);
    CGFloat indicatorLabelHeight = 0.7 * CGRectGetHeight(self.frame);
    CGRect indicatorLabelFrame = CGRectMake(indicatorLabelOriginX, indicatorLabelOriginY, indicatorLabelWidth, indicatorLabelHeight);
    UILabel *indicatorLabel = [[UILabel alloc] initWithFrame:indicatorLabelFrame];
    indicatorLabel.text = indicatorValue;
    indicatorLabel.textColor = [UIColor whiteColor];
    indicatorLabel.font = [UIFont boldSystemFontOfSize:23];
    [self addSubview:indicatorLabel];
}

@end