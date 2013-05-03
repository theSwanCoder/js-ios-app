/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSInputControlCell.h
//  Jaspersoft Corporation
//

#import <jaspersoft-sdk/JaspersoftSDK.h>

#define JS_LBL_VALUE_WIDTH		              160.0f
#define JS_LBL_DEFAULT_WIDTH                  180.0f
#define JS_LBL_WIDTH                          self.nameLabel.frame.size.width
#define JS_CELL_WIDTH                         self.frame.size.width
#define JS_CELL_PADDING                       15.0f
#define JS_CONTENT_PADDING					  10.0f

/**
 @author Giulio Toffoli giulio@jaspersoft.com
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.0
 */
@interface JSInputControlCell : UITableViewCell {
	UILabel *nameLabel;
	CGFloat height;
	NSMutableArray *targetActionsOnChange;
	NSMutableArray *dependetByInputControls;
}

@property (nonatomic, retain) JSResourceDescriptor *descriptor;
@property (nonatomic, retain) JSInputControlDescriptor *icDescriptor;
@property (readonly) BOOL mandatory;
@property (readonly) BOOL readonly;
@property (readonly) BOOL selectable;
@property (nonatomic, assign) BOOL wasModified;

/** 
 * Resource client is used only by query based input controls 
 */
@property (nonatomic, retain) JSRESTResource *resourceClient;

/**
 * Report client is used only for REST v2 cascading IC
 */
@property (nonatomic, retain) JSRESTReport *reportClient;

// Return the list of named parameters from which this control depends
// If there are no dependencies, or there is no query defined in this input control the property returns nil
@property (nonatomic, readonly) NSArray *dependsBy;

// The uri to be used when performing a get on a query based input control
// It is supposed to be the Report Unit data source, and it is passed to the get service
// as value for the parameter IC_GET_QUERY_DATA
@property (nonatomic, retain) NSString *dataSourceUri;

// The label which holds the main text
@property (nonatomic, readonly) UILabel *nameLabel;

// The most appropriate height of this cell
@property (nonatomic, readonly) CGFloat height;

@property (nonatomic, readonly) UITableViewController *tableViewController;

// This is the list of selected value(s). It is a generic id, since it could be 
// NSString, NSMutableArray, NSDate;
// Numbers are stored as NSString, since this is what is expected by JasperReports Server.
// Boolean values are stored as "true" and "false"
@property (nonatomic, retain) id selectedValue;

// Previous selected value. Used by "cancel" loading dialog
@property (nonatomic, retain) id previousSelectedValue;

// Create the most appropriate input control
+ (id)inputControlWithResourceDescriptor:(JSResourceDescriptor *)rd tableViewController:(UITableViewController *)tv
                   dataSourceUri:(NSString *)dsUri resourceClient:(JSRESTResource *)resourceClient;
+ (id)inputControlWithInputControlDescriptor:(JSInputControlDescriptor *)icDescriptor resourceDescriptor:(JSResourceDescriptor *)resourceDescriptor tableViewController:(UITableViewController *)tv reportClient:(JSRESTReport *)reportClient;
- (id)initWithResourceDescriptor:(JSResourceDescriptor *)rd tableViewController:(UITableViewController *)tv;
- (id)initWithResourceDescriptor:(JSResourceDescriptor *)rd tableViewController:(UITableViewController *)tv dataSourceUri: (NSString *)dsUri;
- (id)initWithInputControlDescriptor:(JSInputControlDescriptor *)icDescriptor resourceDescriptor:(JSResourceDescriptor *)resourceDescriptor tableViewController: (UITableViewController *)tv;


// Add an object to be notified when the selectedValue of this inputControl changes
// The action is expected to get a parameter (the sender input control which is changed)
- (void)addTarget:(id)aTarget withAction:(SEL)anAction;


// Add a dependency to another input control. If required, this input control will reload its data
// when the dependent input control changes.
// Under the scenes, this inputcontrols based on a query will add itself as target to the passed input control
- (void)addDependency:(JSInputControlCell *)inputControlCell;

- (void)createNameLabel;

// Find the data type descriptor of an inputControl descriptor
+ (JSResourceDescriptor *)findDataType:(JSResourceDescriptor *)rd forResourceClient:(JSRESTResource *)resourceClient;

// Update the records displayed based on the selection....
// The default implementation does nothing
// Of parameters is nil, it is ignored.
- (void)reloadInputControlQueryData:(NSDictionary *)parameters;
- (void)cellDidSelected;
- (id)formattedSelectedValue;
- (void)updateDependencies;

@end
