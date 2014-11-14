//
//  EvaluationViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 05/09/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "EvaluationGradesViewController.h"

#define CACHE_KEY	@"assessmentsStudentList"
#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"EvaluationVC"]

@interface EvaluationGradesViewController ()

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;

@property (nonatomic, strong) NSIndexPath *selectedRowPath;

@end

@implementation EvaluationGradesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupHandlers {
	BSELF(self);

	self.success = ^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *response = (NSDictionary*)responseObject;

		NSMutableDictionary *periods = [NSMutableDictionary dictionary];
		for (NSDictionary *currentPeriodDico in [response objectForKey:@"periods"]) {
			CloudiversityPeriod *currentPeriod = [CloudiversityPeriod fromJSON:[currentPeriodDico objectForKey:@"period"]];
			
			NSMutableDictionary *disciplines = [NSMutableDictionary dictionary];
			for (NSDictionary *currentDisciplineDico in [currentPeriodDico objectForKey:@"disciplines"]) {
				CloudiversityDiscipline *currentDiscipline = [CloudiversityDiscipline fromJSON:[currentDisciplineDico objectForKey:@"discipline"]];
				
				NSMutableArray *grades = [NSMutableArray array];
				for (NSDictionary *currentGradeDico in [currentDisciplineDico objectForKey:@"grades"]) {
					CloudiversityGrade *currentGrade = [CloudiversityGrade fromJSON:currentGradeDico];
					
					[grades addObject:currentGrade];
				}
				[disciplines setObject:grades forKey:currentDiscipline];
			}
			[periods setObject:disciplines forKey:currentPeriod];
		}
		
		bself.sections = periods;
		[bself reloadTableView];
		[DejalActivityView removeView];
		[((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
	};
	self.failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@: %@", LOCALIZEDSTRING(@"EVALUATION_STUDENT_ERROR"), error);
		switch (operation.response.statusCode) {
			default:
				break;
		}
		[DejalActivityView removeView];
		[((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
	};
}

- (void)initAssessmentsByHTTPRequest {
	[DejalBezelActivityView activityViewForView:self.view withLabel:[NSString stringWithFormat:@"%@...", LOCALIZEDSTRING(@"EVALUATION_STUDENT_LOADING")]].showNetworkActivityIndicator = YES;
	[IOSRequest getGradesForUserOnSuccess:self.success onFailure:self.failure];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[self setupHandlers];

	if ([[EGOCache globalCache] hasCacheForKey:CACHE_KEY]) {
		[self.tableView reloadData];
	} else {
		[self initAssessmentsByHTTPRequest];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView protocols implementation

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 25;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 25)];
	CloudLabel *label = [[CloudLabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width - 20, 25)];
	__block CloudiversityPeriod *period;
	
	__block NSInteger count = 0;
	[self.sections enumerateKeysAndObjectsUsingBlock:^(CloudiversityPeriod *key, id obj, BOOL *stop) {
		if (count == section) {
			period = key;
			*stop = YES;
		}
		count++;
	}];
	
	[label setText:period.name];
	[headerView addSubview:label];
	[headerView setBackgroundColor:[UIColor cloudGrey]];
	
	return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 25)];
	// Put average of the period
	return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"markCell"];

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	__block NSInteger count = 0;
	__block NSUInteger nbRows = 0;

	[self.sections enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary *disciplines, BOOL *stop) {
		if (count == section) {
			nbRows = disciplines.count;
			
			if (self.selectedRowPath) {
				nbRows += [self numberOfGradesAtPosition:[self.selectedRowPath row] inDisciplines:disciplines];
			}
			*stop = YES;
		}
		count++;
	}];

	return nbRows;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.selectedRowPath == nil) {
		self.selectedRowPath = indexPath;
		NSUInteger gradesToAdd = [self numberOfGradesAtPosition:[indexPath row] inDisciplines:[self disciplinesInSection:[indexPath section]]];
		
		NSMutableArray *array = [NSMutableArray array];
		for (int cnt = 1; cnt <= gradesToAdd; cnt++) {
			[array addObject:[NSIndexPath indexPathForRow:([indexPath row] + cnt) inSection:[indexPath section]]];
		}
		[self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationLeft];
	} else if (self.selectedRowPath.section == indexPath.section && self.selectedRowPath.row == indexPath.row) {
		self.selectedRowPath = nil;
		NSUInteger gradesToRemove = [self numberOfGradesAtPosition:[indexPath row] inDisciplines:[self disciplinesInSection:[indexPath section]]];
		
		NSMutableArray *array = [NSMutableArray array];
		for (int cnt = 1; cnt <= gradesToRemove; cnt++) {
			[array addObject:[NSIndexPath indexPathForRow:([indexPath row] + cnt) inSection:[indexPath section]]];
		}
		[self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
		
	}
}

#pragma mark - reusable methods

- (NSUInteger)numberOfGradesAtPosition:(NSUInteger)position inDisciplines:(NSDictionary*)disciplines {
	__block NSUInteger nbGrades = 0;
	__block NSUInteger gradesCount = 0;
	[disciplines enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableArray *grades, BOOL *stop) {
		if (gradesCount == position) {
			nbGrades = grades.count;
			*stop = YES;
		}
		gradesCount++;
	}];

	return nbGrades;
}

- (NSDictionary*)disciplinesInSection:(NSUInteger)section {
	__block NSInteger count = 0;
	__block NSDictionary *disciplinesToReturn;
	
	[self.sections enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary *disciplines, BOOL *stop) {
		if (count == section) {
			disciplinesToReturn = disciplines;
			*stop = YES;
		}
		count++;
	}];
	
	return disciplinesToReturn;
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
