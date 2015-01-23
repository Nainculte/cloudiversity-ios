//
//  EvaluationViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 05/09/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "EvaluationAllGradesViewController.h"
#import "EvaluationGradesViewController.h"

#define CACHE_KEY	@"gradesStudentList"
#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"EvaluationVC"]

@interface EvaluationAllGradesViewController ()

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;

@end

@implementation EvaluationAllGradesViewController

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
	[[NetworkManager manager] getGradesForUserOnSuccess:self.success onFailure:self.failure];
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
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"disciplineCell"];
	
	NSDictionary *disciplines = [self displinesInSection:[indexPath section]];
	CloudiversityDiscipline *discipline = [self disciplineForRow:[indexPath row] inDisciplines:disciplines];
	
	cell.textLabel.text = [discipline.name capitalizedString];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", [self averageOfGrades:[self gradesForRow:[indexPath row] inDisciplines:disciplines]]];

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self displinesInSection:section].count;;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"showGradesSegue"]) {
		NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
		NSDictionary *disciplines = [self displinesInSection:[selectedRow section]];
		[((EvaluationGradesViewController*)segue.destinationViewController) setGrades:[self gradesForRow:[selectedRow row] inDisciplines:disciplines]];
		[((EvaluationGradesViewController*)segue.destinationViewController) setDiscipline:[self disciplineForRow:[selectedRow row] inDisciplines:disciplines]];
	}
}

#pragma mark - reusable methods

- (NSDictionary*)displinesInSection:(NSInteger)section {
	__block NSDictionary *disciplines = nil;
	__block NSInteger cnt = 0;
	[self.sections enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *obj, BOOL *stop) {
		if (cnt == section) {
			disciplines = obj;
			*stop = YES;
		}
		cnt++;
	}];
	
	return disciplines;
}

- (CloudiversityDiscipline*)disciplineForRow:(NSInteger)row inDisciplines:(NSDictionary*)disciplines {
	__block CloudiversityDiscipline *discipline = nil;
	__block NSInteger cnt = 0;
	[disciplines enumerateKeysAndObjectsUsingBlock:^(CloudiversityDiscipline *key, id obj, BOOL *stop) {
		if (cnt == row) {
			discipline = key;
			*stop = YES;
		}
		cnt++;
	}];
	
	return discipline;
}

- (NSArray*)gradesForRow:(NSInteger)row inDisciplines:(NSDictionary*)disciplines {
	__block NSArray *grades = nil;
	__block NSInteger cnt = 0;
	[disciplines enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *obj, BOOL *stop) {
		if (cnt == row) {
			grades = obj;
			*stop = YES;
		}
		cnt++;
	}];
	
	return grades;
}

- (CGFloat)averageOfGrades:(NSArray*)grades {
	CGFloat total = 0;
	CGFloat nbGrades = 0;
	
	for (CloudiversityGrade *grade in grades) {
		total += [grade.note floatValue] * [grade.coefficent floatValue];
		nbGrades += [grade.coefficent floatValue];
	}
	
	return total / nbGrades;
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
