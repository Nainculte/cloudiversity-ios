//
//  CloudiversityViewController.h
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "User.h"
#import "UICloud.h"
#import "UIColor+Cloud.h"
#import <UIKit/UIKit.h>

@interface AuthenticationViewController : UIViewController <UITextFieldDelegate>

- (IBAction)loginBtn:(id)sender;

@property (weak, nonatomic) IBOutlet CloudButton *loginBtn;
@property (weak, nonatomic) IBOutlet CloudTextField *loginField;
@property (weak, nonatomic) IBOutlet CloudTextField *passwordField;
@property (weak, nonatomic) IBOutlet CloudTextField *serverField;
@property (weak, nonatomic) IBOutlet CloudLabel *errorLabel;

@property (nonatomic, strong) User *_user;

// Labels outlet for logo
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *cloudLogo;
@property (weak, nonatomic) IBOutlet CloudLabel *cloudLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *iversityLabel;

- (IBAction)backgroundTap:(id)sender;

@end
