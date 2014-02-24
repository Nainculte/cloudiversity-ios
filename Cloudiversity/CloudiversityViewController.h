//
//  CloudiversityViewController.h
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "User.h"
#import <UIKit/UIKit.h>

@interface CloudiversityViewController : UIViewController <UITextFieldDelegate>

- (IBAction)loginBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *loginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (nonatomic, strong) User *_user;

@end
