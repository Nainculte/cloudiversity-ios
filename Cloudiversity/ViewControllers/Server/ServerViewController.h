//
//  ServerViewController.h
//  Cloudiversity
//
//  Created by Nainculte on 6/19/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractLogoViewViewController.h"

@interface ServerViewController : AbstractLogoViewViewController
@property (weak, nonatomic) IBOutlet CloudTextField *serverField;

- (IBAction)chooseServer;
@end
