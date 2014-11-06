//
//  AgendaFilterViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 08/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"
#import "SWRevealViewController.h"
#import "AgendaStudentViewController.h"
#import "AgendaFilterDelegate.h"

@class AgendaFilterViewController;

@interface AgendaFilterRootViewController : UINavigationController

@property (nonatomic, retain) AgendaFilterViewController *filterVC;

@end

@interface AgendaFilterViewController : XLFormViewController

@property (nonatomic, weak) id<AgendaFilterDelegate> delegate;
@property (nonatomic, weak) id<AgendaStudentDataSource> dataSource;

@end