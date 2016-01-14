/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMReportOptionsViewController.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 2.2
 */


#import "GAITrackedViewController.h"
#import "JSReportOption.h"

@class JMReportOptionsViewController;
@protocol JMReportOptionsViewControllerDelegate <NSObject>

@required
- (void) reportOptionsViewController:(JMReportOptionsViewController *)controller didSelectOption:(JSReportOption *)option;

@end

@interface JMReportOptionsViewController : GAITrackedViewController

@property (nonatomic, strong) NSArray *listOfValues;
@property (nonatomic, strong) JSReportOption *selectedReportOption;
@property (nonatomic, weak) id <JMReportOptionsViewControllerDelegate> delegate;
@end
