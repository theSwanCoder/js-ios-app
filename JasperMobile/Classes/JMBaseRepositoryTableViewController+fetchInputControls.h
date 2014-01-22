/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMBaseRepositoryTableViewController+fetchInputControls.h
//  Jaspersoft Corporation
//

extern NSString * const kJMShowReportOptionsSegue;
extern NSString * const kJMShowReportViewerSegue;

#import "JMBaseRepositoryTableViewController.h"

/**
 Adds possibility to get list of input controls for report directly in repository
 
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.8
 */
@interface JMBaseRepositoryTableViewController (fetchInputControls)

/**
 Gets input controls for specified report and calls segue depending on a request result
 */
- (void)fetchInputControlsForReport:(JSResourceLookup *)resourceLookup;

/**
 Sets resource lookup and (if exists) fetched input controls to destination view controller. Destination could
 be <b>JMReportOptionsTableViewController</b> or <b>JMReportViewerViewController</b> view controller
 */
- (void)setResults:(id)sender toDestinationViewController:(id)viewController;

/**
 Indicates if segue has a "ShowReportOptions" or "ShowReportViewer" identifier
 */
- (BOOL)isReportSegue:(UIStoryboardSegue *)segue;

@end
