//
//  JMReportSearchTableViewCell.h
//  TIBCO JasperMobile
//
//  Created by Alexey Gubarev on 8/8/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSReportSearchResult.h"

@interface JMReportSearchTableViewCell : UITableViewCell
@property (nonatomic, strong, nonnull) JSReportSearchResult *searchResult;
@end
