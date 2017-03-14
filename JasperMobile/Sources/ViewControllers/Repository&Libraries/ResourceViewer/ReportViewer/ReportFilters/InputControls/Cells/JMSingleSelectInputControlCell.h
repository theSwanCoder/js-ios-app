/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.6
 */

#import "JMInputControlCell.h"

@interface JMSingleSelectInputControlCell : JMInputControlCell

/**
 Forces to reload data for dependent Input Controls (if exists)
 */
- (void)updateWithParameters:(NSArray *)parameters;

@end
