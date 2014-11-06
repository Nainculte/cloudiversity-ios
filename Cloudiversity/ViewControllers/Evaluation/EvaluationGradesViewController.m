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

@property (nonatomic, strong) NSMutableDictionary *grades; // Classed by disciplines name
@property (nonatomic, strong) NSMutableDictionary *averages; // Classed by disciplines name

@property NSInteger plop;
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

		bself.grades = [NSMutableDictionary dictionary];
		bself.averages = [NSMutableDictionary dictionary];
		for (NSDictionary *currentPeriodDico in [response objectForKey:@"periods"]) {
			CloudiversityPeriod *currentPeriod = [CloudiversityPeriod fromJSON:[currentPeriodDico objectForKey:@"period"]];
			for (NSDictionary *currentDisciplineDico in [currentPeriodDico objectForKey:@"disciplines"]) {
				CloudiversityDiscipline *currentDiscipline = [CloudiversityDiscipline fromJSON:[currentDisciplineDico objectForKey:@"discipline"]];
				NSMutableArray *grades = [NSMutableArray array];
				
				for (NSDictionary *currentGradeDico in [currentDisciplineDico objectForKey:@"grades"]) {
					CloudiversityGrade *currentGrade = [CloudiversityGrade fromJSON:currentGradeDico];
					currentGrade.period = currentPeriod;
					currentGrade.discipline = currentDiscipline;
					
					[grades addObject:currentGrade];
				}
				
				NSMutableArray *selfGrades;
				if ((selfGrades = [bself.grades objectForKey:currentDiscipline.name])) {
					[selfGrades addObjectsFromArray:grades];
				} else {
					selfGrades = grades;
				}
				[bself.grades setObject:selfGrades forKey:currentDiscipline.name];
				
				// Calculating average
				double total = 0;
				for (CloudiversityGrade *grade in selfGrades) {
					total += ([grade.note integerValue] * [grade.coefficent integerValue]);
				}
				[bself.averages setObject:[NSNumber numberWithDouble:(total/selfGrades.count)] forKey:currentDiscipline.name];
			}
		}
		
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
	
	self.plop = NSNotFound;
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
	CloudLabel *disciplineNameLabel = [[CloudLabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 25)];
	
	[headerView setBackgroundColor:[UIColor cloudGrey]];
	disciplineNameLabel.font = [UIFont fontWithName:@"FiraSansOt-Bold" size:disciplineNameLabel.font.pointSize];
	
	__block NSInteger count = 0;
	[self.grades enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (count == section) {
			[disciplineNameLabel setText:(NSString*)key];
			*stop = YES;
		}
		*stop = NO;
		count++;
	}];
	[headerView addSubview:disciplineNameLabel];
	
	return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 25)];
	CloudLabel *disciplineNameLabel = [[CloudLabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 25)];
	
	[headerView setBackgroundColor:[UIColor cloudGrey]];
	disciplineNameLabel.font = [UIFont fontWithName:@"FiraSansOt-Bold" size:disciplineNameLabel.font.pointSize];
	
	__block NSInteger count = 0;
	[self.grades enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (count == section) {
			[disciplineNameLabel setText:(NSString*)key];
			*stop = YES;
		}
		*stop = NO;
		count++;
	}];
	[headerView addSubview:disciplineNameLabel];
	
	return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"markCell"];
	
	__block NSInteger count = 0;

	[self.grades enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
		if (count == [indexPath section]) {

			CloudiversityGrade *grade = [obj objectAtIndex:([indexPath row])];
			
			cell.textLabel.text = [grade.note stringValue];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"(Coefficient: %ld)", [grade.coefficent integerValue]];
			*stop = YES;
		}
		*stop = NO;
		count++;
	}];

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.grades.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	__block NSInteger count = 0;
	__block NSArray *grades;
	
	[self.grades enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (count == section) {
			grades = obj;
			*stop = YES;
		}
		*stop = NO;
		count++;
	}];
	
	switch (self.plop) {
  case 0:
			return grades.count - 2;
			break;
			
  default:
			return grades.count;
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableArray *array = [NSMutableArray array];
	
	for (int cnt = 0; cnt < 2; cnt++) {
		[array addObject:[NSIndexPath indexPathForRow:(indexPath.row + cnt) inSection:indexPath.section]];
	}
	
	if (self.plop != 0) {
		self.plop = 0;
		[self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
	} else if (self.plop == 0) {
		self.plop = 1;
		[self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
	}
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
