//
//  AgendaFilterViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 08/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaFilterViewController.h"

@interface AgendaFilterViewController ()

@end

@implementation AgendaFilterViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)returnButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
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
