//
//  AbstractTableViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 14/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractTableViewController.h"

@interface AbstractTableViewController ()

@end

@implementation AbstractTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.toolbar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.toolbar setBarTintColor:[UIColor cloudLightBlue]];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)reuseIdentifier
{
    return @"";
}

+ (Class)cellClass
{
    return [UITableViewCell class];
}

#pragma mark - UITableView Delegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections objectForKey:[self.sortedSections objectAtIndex:section]] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
	if (!cell) {
		cell = [[[AbstractTableViewController cellClass] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reuseIdentifier]];
	}
    [self setupCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)setupCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
