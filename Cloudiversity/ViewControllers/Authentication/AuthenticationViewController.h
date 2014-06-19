//
//  CloudiversityViewController.h
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UICloud.h"
#import "AbstractLogoViewViewController.h"

@interface AuthenticationViewController : AbstractLogoViewViewController <UITextFieldDelegate>

- (IBAction)loginBtn:(id)sender;

@property (weak, nonatomic) IBOutlet CloudTextField *loginField;
@property (weak, nonatomic) IBOutlet CloudTextField *passwordField;

@property (nonatomic, strong) User *_user;

@end
