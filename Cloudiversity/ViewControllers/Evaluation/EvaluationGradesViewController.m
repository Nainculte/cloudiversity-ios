//
//  EvaluationGradesViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 18/12/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "EvaluationGradesViewController.h"
#import "EvaluationGradeDetailViewController.h"

@interface EvaluationGradesViewController ()

@end

@implementation EvaluationGradesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self.navigationController.navigationBar.topItem setTitle:self.discipline.name];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewController protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.grades.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"gradeCell"];
	
	CloudiversityGrade *grade = [self.grades objectAtIndex:[indexPath row]];
	
	cell.textLabel.text = [grade.note stringValue];
	cell.detailTextLabel.text = [@"Coeff.: " stringByAppendingString:[grade.coefficent stringValue]];
	
	return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"gradeDetailSegue"]) {
		NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
		
		[((EvaluationGradeDetailViewController*)segue.destinationViewController) setGrade:[self.grades objectAtIndex:[selectedPath row]]];
		[((EvaluationGradeDetailViewController*)segue.destinationViewController) setDiscipline:self.discipline];
	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
