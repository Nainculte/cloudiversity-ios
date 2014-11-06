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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadTableView) forControlEvents:UIControlEventValueChanged];

    self.leftButton.target = self.revealViewController;
    self.leftButton.action = @selector(revealToggle:);

    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.view.backgroundColor = [UIColor cloudGrey];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor cloudLightBlue]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)reloadTableView
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)setRightViewController:(NSString *)name withButton:(UIBarButtonItem *)button
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    self.revealViewController.rightViewController = [sb instantiateViewControllerWithIdentifier:name];
    if (button) {
        button.target = self.revealViewController;
        button.action = @selector(rightRevealToggle:);
    }
}

- (void)setRightViewController:(NSString *)name
{
    [self setRightViewController:name withButton:nil];
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
    return [(self.sections)[(self.sortedSections)[section]] count];
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

@end
