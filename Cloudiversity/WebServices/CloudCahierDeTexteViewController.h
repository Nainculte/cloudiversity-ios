//
//  CloudCahierDeTexteViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudTextField.h"

@interface CloudCahierDeTexteViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UISwitch *controlSwitchFilter;
@property (weak, nonatomic) IBOutlet UISwitch *exercicesSwitchFilter;
@property (weak, nonatomic) IBOutlet UISwitch *markesTasksSwitchFilter;
@property (weak, nonatomic) IBOutlet CloudTextField *fieldFilterTextField;

@end
