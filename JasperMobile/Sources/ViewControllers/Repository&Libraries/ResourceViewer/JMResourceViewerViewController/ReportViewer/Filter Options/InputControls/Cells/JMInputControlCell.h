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
//  JMInputControlCell.h
//  TIBCO JasperMobile
//

#import <UIKit/UIKit.h>

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.6
 */

@class JMInputControlCell;
@protocol JMInputControlCellDelegate <NSObject>
@required
- (void) reloadTableViewCell:(JMInputControlCell *)cell;

- (void) updatedInputControlsValuesWithDescriptor:(JSInputControlDescriptor *)descriptor;
@end

@interface JMInputControlCell : UITableViewCell 

@property (nonatomic, strong) JSInputControlDescriptor *inputControlDescriptor;
@property (nonatomic, weak) id <JMInputControlCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

- (void) updateDisplayingOfErrorMessage;
- (void) setEnabledCell:(BOOL) enabled;

@end
