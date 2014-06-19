//
//  AbstractLogoViewViewController.h
//  Cloudiversity
//
//  Created by Nainculte on 6/19/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICloud.h"

@interface AbstractLogoViewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *cloudLogo;
@property (weak, nonatomic) IBOutlet CloudLabel *cloudLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *iversityLabel;
@property (weak, nonatomic) IBOutlet UIView *textfields;
@property (weak, nonatomic) IBOutlet CloudLabel *errorLabel;
@property (weak, nonatomic) IBOutlet CloudButton *button;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *borders;

@property (nonatomic) BOOL shouldAnimate;
@property (nonatomic) BOOL hasSelected;

- (IBAction)backgroundTap:(id)sender;

@end
