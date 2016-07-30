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
//  JMReportPartViewToolbar.h
//  TIBCO JasperMobile
//


/**
 @author Aleksandr Dakhno odahno@tibco.com
 @since 2.6
 */

@import UIKit;

@class JSReportPart;
@protocol JMReportPartViewToolbarDelegate;


@interface JMReportPartViewToolbar : UIView
@property (nonatomic, strong, readonly) JSReportPart *currentPart;
@property (nonatomic, strong) NSArray <JSReportPart *> *parts;
@property (nonatomic, weak) NSObject <JMReportPartViewToolbarDelegate> *delegate;
- (void)updateCurrentPartForPage:(NSInteger)page;
@end

@protocol JMReportPartViewToolbarDelegate
@optional
- (void)reportPartViewToolbarDidChangePart:(JMReportPartViewToolbar *)toolbar;
@end