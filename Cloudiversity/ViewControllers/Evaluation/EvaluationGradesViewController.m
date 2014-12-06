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
@property (nonatomic, strong) NSMutableArray *disciplinesIndexPaths; // A memory view of the indexPaths of disciplines (Array of Arrays of IndexPaths)

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
//		[bself initDisciplinesIndexPaths];
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
	
	self.disciplinesIndexPaths = [NSMutableArray array];
	
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

	cell.textLabel.text = [NSString stringWithFormat:@"{%ld - %ld}", (long)indexPath.section, (long)indexPath.row];
	
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
		// Uncollapse discipline
		self.selectedRowPath = indexPath;
		NSUInteger gradesToAdd = [self numberOfGradesAtPosition:[indexPath row] inDisciplines:[self disciplinesInSection:[indexPath section]]];
		
		NSMutableArray *array = [NSMutableArray array];
		for (int cnt = 1; cnt <= gradesToAdd; cnt++) {
			[array addObject:[NSIndexPath indexPathForRow:([indexPath row] + cnt) inSection:[indexPath section]]];
		}
		[self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationLeft];
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	} else if (self.selectedRowPath.section == indexPath.section && self.selectedRowPath.row == indexPath.row) {
		// Collapse discipline
		self.selectedRowPath = nil;
		NSUInteger gradesToRemove = [self numberOfGradesAtPosition:[indexPath row] inDisciplines:[self disciplinesInSection:[indexPath section]]];
		
		NSMutableArray *array = [NSMutableArray array];
		for (int cnt = 1; cnt <= gradesToRemove; cnt++) {
			[array addObject:[NSIndexPath indexPathForRow:([indexPath row] + cnt) inSection:[indexPath section]]];
		}
		[self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationLeft];
	} else if ((self.selectedRowPath.row != indexPath.row && self.selectedRowPath.section == indexPath.section) ||
			   self.selectedRowPath.section != indexPath.section) {
		// Collapse previous uncollapsed discipline, and uncollapse selected discipline
		NSIndexPath *newIndexPath;
		NSUInteger gradesToAdd;
		NSUInteger gradesToRemove = [self numberOfGradesAtPosition:[self.selectedRowPath row] inDisciplines:[self disciplinesInSection:[self.selectedRowPath section]]];
		
		if (self.selectedRowPath.section == indexPath.section && self.selectedRowPath.row < indexPath.row) {
			newIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - gradesToRemove) inSection:indexPath.section];
		} else {
			newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
		}
		
		gradesToAdd = [self numberOfGradesAtPosition:newIndexPath.row inDisciplines:[self disciplinesInSection:newIndexPath.section]];

		NSMutableArray *array = [NSMutableArray array];
		for (int cnt = 1; cnt <= gradesToRemove; cnt++) {
			[array addObject:[NSIndexPath indexPathForRow:([self.selectedRowPath row] + cnt) inSection:[self.selectedRowPath section]]];
		}
		self.selectedRowPath = nil;
		[self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationLeft];

		array = [NSMutableArray array];
		for (int cnt = 1; cnt <= gradesToAdd; cnt++) {
			[array addObject:[NSIndexPath indexPathForRow:([newIndexPath row] + cnt) inSection:[newIndexPath section]]];
		}
		self.selectedRowPath = newIndexPath;
		[self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationLeft];
	}
}

#pragma mark - reusable methods

- (void)initDisciplinesIndexPaths {
	BSELF(self);
	
	__block NSUInteger section = 0;
	[self.sections enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *disciplines, BOOL *stop) {
		NSMutableArray *disciplinesIndexes = [NSMutableArray array];
		__block NSUInteger row = 0;
		[disciplines enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[disciplinesIndexes addObject:[NSIndexPath indexPathForRow:row inSection:section]];
			row++;
		}];
		[bself.disciplinesIndexPaths addObject:disciplinesIndexes];
		section++;
	}];
}

- (void)updateDisciplinesIndexPathsWithExpandingIndexPath:(NSIndexPath*)expandingIndexPath
								   andCollapsingIndexPath:(NSIndexPath*)collapsingIndexPath {
	NSMutableArray *disciplinesIndexes = [self.disciplinesIndexPaths objectAtIndex:[collapsingIndexPath section]];
	NSUInteger nbGrades = [self numberOfGradesAtPosition:[collapsingIndexPath row] inDisciplines:[self disciplinesInSection:[collapsingIndexPath section]]];
	for (NSUInteger cnt = [collapsingIndexPath row]; cnt < disciplinesIndexes.count; cnt++) {
	}
}

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
