/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

@import UIKit;

@protocol JMResourceClientHolder;

@interface JMResourceViewerFavoritesHelper : NSObject
@property (nonatomic, weak) UIViewController <JMResourceClientHolder>*controller;
- (void)updateAppearence;
- (void)updateFavoriteState;
- (void)removeFavoriteBarButton;
- (BOOL)shouldShowFavoriteBarButton;

- (BOOL)isResourceInFavorites;

@end
