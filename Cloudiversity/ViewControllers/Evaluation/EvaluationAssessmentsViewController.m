//
//  CloudAssessmentsViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 19/12/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "EvaluationAssessmentsViewController.h"
#import "EvaluationAssessmentDetailsViewController.h"
#import "EvaluationAssessmentsModificationViewController.h"
#import "CloudEvaluationObjects.h"
#import "User.h"

@interface EvaluationAssessmentsViewController ()

@property (strong, nonatomic) CloudiversityAssessment *selectedAssessment;

@end

@implementation EvaluationAssessmentsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.navigationController.navigationBar.topItem setTitle:self.discipline.name];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewController protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.assessments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"assessmentCell"];
	
	cell.textLabel.text = ((CloudiversityAssessment*)[self.assessments objectAtIndex:[indexPath row]]).assessment;
	
	return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"assessmentDetailSegue"]) {
		NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
		
		[((EvaluationAssessmentDetailsViewController*)segue.destinationViewController) setAssessment:[self.assessments objectAtIndex:[selectedPath row]]];
		[((EvaluationAssessmentDetailsViewController*)segue.destinationViewController) setDiscipline:self.discipline];
	} else if ([segue.identifier isEqualToString:@"assessmentModifSegue"]) {
		EvaluationAssessmentsModificationViewController *modifVC = segue.destinationViewController;
		
		modifVC.isCreatingAssessment = NO;
		modifVC.assessment = self.selectedAssessment;
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[User sharedUser].currentRole isEqualToString:UserRoleTeacher]) {
		self.selectedAssessment = [self.assessments objectAtIndex:indexPath.row];
		[self performSegueWithIdentifier:@"assessmentModifSegue" sender:self];
	} else {
		[self performSegueWithIdentifier:@"assessmentDetailSegue" sender:self];
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
