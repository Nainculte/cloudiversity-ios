//
//  AbstractTableViewController.h
//  Cloudiversity
//
//  Created by Nainculte on 14/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudiversityAppDelegate.h"
#import "UICloud.h"
#import "UIColor+Cloud.h"
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import "SWRevealViewController.h"
#import "EGOCache.h"
#import "User.h"

@interface AbstractTableViewController : UITableViewController <UITableViewDataSource, CloudTableViewDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;

- (void)setRightViewController:(NSString *)name withButton:(UIBarButtonItem *)button;
- (void)setRightViewController:(NSString *)name;

@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSArray *sortedSections;

- (void)reloadTableView;

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
+ (Class)cellClass;

- (void)setupCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath;
@end
