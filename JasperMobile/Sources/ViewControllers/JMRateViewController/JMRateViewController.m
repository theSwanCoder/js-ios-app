//
//  JMRateViewController.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 11/18/15.
//  Copyright © 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMRateViewController.h"
#import "AGRateView.h"
#import <MessageUI/MessageUI.h>

NSString *const kJMRateViewNPSUserValue = @"JMRateViewNPSUserValue";

@interface JMRateViewController () <AGRateViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet AGRateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLbl;

@end

@implementation JMRateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rateView.delegate = self;
    self.rateView.rating = 5;
    [self rateView:self.rateView didChangedRating:5];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonTapped:(id)sender
{
   // [JMUtils logEventWithName:@"NPS" additionInfo:@{kJMRateViewNPSUserValue : [NSNumber numberWithInt:self.rateView.rating]}];
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:nil
                                                                                      message:nil
                                                                            cancelButtonTitle:@"dialog.button.cancel"
                                                                      cancelCompletionHandler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                                      }];
    switch (self.rateView.rating) {
        case 0 ... 3: {
            alertController.title = JMCustomLocalizedString(@"Sorry!", nil);
            alertController.message = @"Do you want to send feedback about app?";
            [alertController addActionWithLocalizedTitle:@"Yes" style:UIAlertActionStyleDefault handler:nil];
            break;
        }
        case 4 ... 7: {
            alertController.title = JMCustomLocalizedString(@"Warning!", nil);
            alertController.message = @"Do you want to send feedback about new features?";
            [alertController addActionWithLocalizedTitle:@"Yes" style:UIAlertActionStyleDefault handler:nil];
            break;
        }
        default: {
            alertController.title = JMCustomLocalizedString(@"Thanks!", nil);
            alertController.message = @"Thank you very much for your rate!";
            [alertController addActionWithLocalizedTitle:@"Refer Friends" style:UIAlertActionStyleDefault handler:nil];
            [alertController addActionWithLocalizedTitle:@"Rate on market" style:UIAlertActionStyleDefault handler:nil];
            break;
        }
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - AGRateViewDelegate
- (void)rateView:(AGRateView *)rateView didChangedRating:(NSInteger)rating
{
    self.ratingLbl.text = [NSString stringWithFormat:@"Rating is: %zd", rating];
    NSLog(@"Rating: %zd", rating);
}
@end
