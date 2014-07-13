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

@interface AbstractViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;

@end
