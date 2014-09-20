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
#import "IOSRequest.h"
#import "DejalActivityView.h"
#import "SWRevealViewController.h"
#import "EGOCache.h"
#import "User.h"

#define BSELF(ptr) __weak typeof(ptr) bself = ptr;

@interface AbstractViewController : UIViewController <SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;

- (void)setRightViewController:(NSString *)name withButton:(UIBarButtonItem *)button;
- (void)setRightViewController:(NSString *)name;

@end
