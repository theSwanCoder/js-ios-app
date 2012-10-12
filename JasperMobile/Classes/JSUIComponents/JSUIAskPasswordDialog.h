//
//  JSUIAskPasswordDialog.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 10.10.12.
//
//

#import <jaspersoft-sdk/JSProfile.h>

@interface JSUIAskPasswordDialog : NSObject <UIAlertViewDelegate, UITextFieldDelegate>

+ (UIAlertView *)askPasswordDialogForProfile:(JSProfile *)profile delegate:(id)delegate updateMethod:(SEL)updateMethod;
- (id)initWithProfile:(JSProfile *)profile callback:(id)callback updateMethod:(SEL)updateMethod;

@end
