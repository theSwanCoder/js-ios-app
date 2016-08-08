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
    self.textLabel.text = [NSString stringWithFormat:JMCustomLocalizedString(@"report_viewer_report_search_hitCount_format", nil), searchResult.hitCount];
    self.detailTextLabel.text = [NSString stringWithFormat:JMCustomLocalizedString(@"report_viewer_report_search_page_format", nil), searchResult.page];
}

@end
