//
//  CloudCahierDeTexteViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "CloudCahierDeTexteViewController.h"

@interface CloudCahierDeTexteViewController ()

@property BOOL isFilteringExams;
@property BOOL isFilteringExercices;
@property BOOL isFilteringNotedTasks;
@property (nonatomic, strong) NSString *filteringMatiere;

@end

@implementation CloudCahierDeTexteViewController

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
    // Do any additional setup after loading the view.
	[self.controlSwitchFilter setOn:NO];
	[self.exercicesSwitchFilter setOn:NO];
	[self.markesTasksSwitchFilter setOn:NO];
	[self.filterView setAlpha:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)returnButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateSwitches:(id)sender {
	if ([sender isEqual:self.controlSwitchFilter]) {
		if ([self.controlSwitchFilter isOn]) {
			[self.exercicesSwitchFilter setOn:NO animated:YES];
			[self.markesTasksSwitchFilter setOn:NO animated:YES];
		}
	} else if ([sender isEqual:self.exercicesSwitchFilter]) {
		if ([self.exercicesSwitchFilter isOn]) {
			[self.controlSwitchFilter setOn:NO animated:YES];
			[self.markesTasksSwitchFilter setOn:NO animated:YES];
		}
	} else {
		if ([self.markesTasksSwitchFilter isOn]) {
			[self.controlSwitchFilter setOn:NO animated:YES];
			[self.exercicesSwitchFilter setOn:NO animated:YES];
		}
	}
}

- (IBAction)updateFilters:(id)sender {
	[UIView animateWithDuration:0.5 animations:^{
		[self.filterView setAlpha:0];
	}];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.fieldFilterTextField resignFirstResponder];
	[self.fieldFilterTextField endEditing:YES];
	return NO;
}

- (IBAction)showFilterOptionsAsked:(id)sender {
	[UIView animateWithDuration:0.5 animations:^{
		[self.filterView setAlpha:1];
	}];
}

@end
