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
//  JMGaugeKPIView.m
//  TIBCO JasperMobile
//

#import "JMGaugeKPIView.h"
#import "JMBaseKPIModel.h"


@implementation JMGaugeKPIView

#pragma mark - Public API
- (void)setupViewWithKPIModel:(JMBaseKPIModel *)kpiModel
{
    self.backgroundColor = [UIColor colorWithRed:24/255.0f green:27/255.0f blue:31/255.0f alpha:1.0];

    [self setupIndicatorTextWithModel:kpiModel];
    [self setupGraphWithModel:kpiModel];
}

#pragma mark - Private API
- (void)setupIndicatorTextWithModel:(JMBaseKPIModel *)kpiModel
{
    CGFloat indicatorLabelOriginX = 0.1 * CGRectGetWidth(self.frame);
    CGFloat indicatorLabelOriginY = 0.2 * CGRectGetHeight(self.frame);
    CGFloat indicatorLabelWidth = 0.8 * CGRectGetWidth(self.frame);
    CGFloat indicatorLabelHeight = 0.2 * CGRectGetHeight(self.frame);
    CGRect indicatorLabelFrame = CGRectMake(indicatorLabelOriginX, indicatorLabelOriginY, indicatorLabelWidth, indicatorLabelHeight);
    UILabel *indicatorLabel = [[UILabel alloc] initWithFrame:indicatorLabelFrame];

    double indicatorValue = (kpiModel.value.doubleValue * 100) / kpiModel.target.doubleValue;
    NSString *indicatorValueString = [NSString stringWithFormat:@"%.0f%% of goal", indicatorValue];

    NSMutableAttributedString *indicatorValueAttributedString = [[NSMutableAttributedString alloc] initWithString:indicatorValueString];

    // setup value font
    NSDictionary *valueAttributes = @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName : [UIFont boldSystemFontOfSize:16]
    };
    NSRange valueRange = [indicatorValueString rangeOfString:[NSString stringWithFormat:@"%.0f", indicatorValue]];
    [indicatorValueAttributedString addAttributes:valueAttributes range:valueRange];

    // setup percent sign font
    NSDictionary *percentSignAttributes = @{
            NSForegroundColorAttributeName: [UIColor grayColor],
            NSFontAttributeName : [UIFont italicSystemFontOfSize:12]
    };
    NSRange percentSignRange = [indicatorValueString rangeOfString:@"%"];
    [indicatorValueAttributedString addAttributes:percentSignAttributes range:percentSignRange];


    // description font
    NSDictionary *descriptionAttributes = @{
            NSForegroundColorAttributeName: [UIColor grayColor],
            NSFontAttributeName : [UIFont italicSystemFontOfSize:12]
    };
    NSRange descriptionRange = [indicatorValueString rangeOfString:@" of goal"];
    [indicatorValueAttributedString addAttributes:descriptionAttributes range:descriptionRange];

    // set text
    indicatorLabel.attributedText = indicatorValueAttributedString;
    //indicatorLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:indicatorLabel];
}

- (void)setupGraphWithModel:(JMBaseKPIModel *)kpiModel
{
    CGFloat graphOriginX = 0.1 * CGRectGetWidth(self.frame);
    CGFloat graphOriginY = 0.45 * CGRectGetHeight(self.frame);
    CGFloat graphWidth = 0.8 * CGRectGetWidth(self.frame);
    CGFloat graphHeight = 0.35 * CGRectGetHeight(self.frame);
    CGRect graphFrame = CGRectMake(graphOriginX, graphOriginY, graphWidth, graphHeight);

    UIImageView *graphView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sample_gauge"]];
    graphView.frame = graphFrame;
    [self addSubview:graphView];
}

@end