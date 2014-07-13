//
//  AgendaViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractViewController.h"

@interface AgendaViewController : AbstractViewController <UITableViewDataSource, CloudTableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filters;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end
