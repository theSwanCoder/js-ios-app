//
//  JSUIFavoritesViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 21.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import "JSUIRepositoryViewController.h"

@interface JSUIFavoritesViewController : JSUIRepositoryViewController

@property (nonatomic, retain) UIBarButtonItem *editDoneButton;
@property (nonatomic, assign) BOOL editMode;

@end
