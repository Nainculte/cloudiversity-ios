//
//  AbstractTableViewController.h
//  Cloudiversity
//
//  Created by Nainculte on 14/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractViewController.h"

@interface AbstractTableViewController : AbstractViewController <UITableViewDataSource, CloudTableViewDelegate>

@property (weak, nonatomic) IBOutlet CloudTableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSArray *sortedSections;


- (NSString *)reuseIdentifier;
+ (Class)cellClass;

- (void)setupCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath;
@end
