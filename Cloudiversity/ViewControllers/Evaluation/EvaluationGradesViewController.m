//
//  EvaluationGradesViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 18/12/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "EvaluationGradesViewController.h"
#import "EvaluationGradeDetailViewController.h"
#import "EvaluationGradeModificationViewController.h"

@interface EvaluationGradesViewController ()

@property (strong, nonatomic) CloudiversityGrade *selectedGrade;

@end

@implementation EvaluationGradesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(createGrade)];
	[self.navigationController.navigationBar.topItem setRightBarButtonItem:editButton animated:NO];
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
	} else if ([segue.identifier isEqualToString:@"gradeModifSegue"]) {
		EvaluationGradeModificationViewController *modifVC = segue.destinationViewController;
		
		modifVC.isCreatingGrade = NO;
		modifVC.grade = self.selectedGrade;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[User sharedUser].currentRole isEqualToString:UserRoleTeacher]) {
		self.selectedGrade = [self.grades objectAtIndex:[indexPath row]];
		
		[self performSegueWithIdentifier:@"gradeModifSegue" sender:self];
	} else {
		[self performSegueWithIdentifier:@"gradeDetailSegue" sender:self];
	}
}

- (void)createGrade {
	EvaluationGradeModificationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EvaluationGradeModificationViewController"];
	
	vc.isCreatingGrade = YES;
	vc.grade = nil;
	
	[self.navigationController pushViewController:vc animated:YES];
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
