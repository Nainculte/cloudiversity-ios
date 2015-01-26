//
//  AbstractViewController.h
//  Cloudiversity
//
//  Created by Nainculte on 7/9/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudiversityAppDelegate.h"
#import "UICloud.h"
#import "UIColor+Cloud.h"
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import "SWRevealViewController.h"
#import "User.h"

@interface AbstractViewController : UIViewController <SWRevealViewControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem *leftButton;
@property (nonatomic) BOOL showMenuButton;

- (void)setRightViewController:(NSString *)name withButton:(UIBarButtonItem *)button;
- (void)setRightViewController:(NSString *)name;

@end
