//
//  JMReportSearchTableViewCell.m
//  TIBCO JasperMobile
//
//  Created by Alexey Gubarev on 8/8/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportSearchTableViewCell.h"
#import "JMLocalization.h"

@implementation JMReportSearchTableViewCell

- (void)setSearchResult:(JSReportSearchResult *)searchResult
{
    self.textLabel.text = [NSString stringWithFormat:JMLocalizedString(@"report_viewer_report_search_hitCount_format"), searchResult.hitCount];
    self.detailTextLabel.text = [NSString stringWithFormat:JMLocalizedString(@"report_viewer_report_search_page_format"), searchResult.page];
}

@end
