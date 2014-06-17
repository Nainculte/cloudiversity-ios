//
//  AgendaViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaViewController.h"
#import "AgendaTableViewCell.h"
#import "SWRevealViewController.h"

// id for cells in the tableView
#define REUSE_IDENTIFIER	@"agendaCell"

@interface AgendaViewController ()

@property BOOL isFilteringExams;
@property BOOL isFilteringExercices;
@property BOOL isFilteringNotedTasks;
@property (nonatomic, strong) NSMutableArray *materialsToFilter;

@end

@implementation AgendaViewController

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
    self.leftButton.target = self.revealViewController;
    self.leftButton.action = @selector(revealToggle:);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)returnButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView management

/*
 For getting the number of rows in a section, we check the number of assignement per day
*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 10;
}

/*
 Maybe a number like 10, to have assignements for the 10 next days
 (have to talk about it)
*/
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 10;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	AgendaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSE_IDENTIFIER];
	if (!cell) {
		cell = [[AgendaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE_IDENTIFIER];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
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
