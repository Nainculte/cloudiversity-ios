//
//  EvaluationAssessmentsViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 19/12/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "EvaluationAllAssessmentsViewController.h"
#import "EvaluationAssessmentsViewController.h"
#import "EvaluationAssessmentsModificationViewController.h"
#import "User.h"

#define CACHE_KEY	@"assessmentsStudentList"
#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"EvaluationVC"]

@interface EvaluationAllAssessmentsViewController ()

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;
@property (nonatomic, strong) NSDictionary *teachings;

@end

@implementation EvaluationAllAssessmentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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
				
				NSMutableArray *assessments = [NSMutableArray array];
				for (NSDictionary *currentAssessmentDico in [currentDisciplineDico objectForKey:@"assessments"]) {
					CloudiversityAssessment *currentAssessment = [CloudiversityAssessment fromJSON:currentAssessmentDico];
					
					[assessments addObject:currentAssessment];
				}
				[disciplines setObject:assessments forKey:currentDiscipline];
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
	[[NetworkManager manager] getAssessmentsForUserOnSuccess:self.success onFailure:self.failure];
}

- (void)setupTeachings {
#warning TOCHECK
	HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, NSArray *response) {
		//		NSLog(@"%@", response);
		
		NSMutableDictionary *newTeachings = [NSMutableDictionary dictionary];
		for (NSDictionary *teachings in response) {
			CloudiversityDiscipline *discipline = [CloudiversityDiscipline fromJSON:[teachings objectForKey:@"discipline"]];
			NSMutableArray *newClasses = [NSMutableArray array];
			for (NSDictionary *classes in [teachings objectForKey:@"school_classes"]) {
				CloudiversityClass *newClass = [CloudiversityClass fromJSON:classes];
				[newClasses addObject:newClass];
			}
			[newTeachings setObject:newClasses forKey:discipline];
		}
		self.teachings = newTeachings;
	};
	
	NSArray *response = @[
						  @{@"discipline":@{@"id":@7,@"name":@"Transfiguration"},
							@"school_classes":@[
									@{@"school_class_id":@13,@"school_class_name":@"Gryffindor",@"period_id":@28,@"period_name":@"5th Year"},
									@{@"school_class_id":@14,@"school_class_name":@"Gryffindor",@"period_id":@29,@"period_name":@"6th Year"},
									@{@"school_class_id":@16,@"school_class_name":@"Slytherin",@"period_id":@28,@"period_name":@"5th Year"},
									@{@"school_class_id":@17,@"school_class_name":@"Slytherin",@"period_id":@29,@"period_name":@"6th Year"},
									@{@"school_class_id":@19,@"school_class_name":@"Ravenclaw",@"period_id":@28,@"period_name":@"5th Year"},
									@{@"school_class_id":@20,@"school_class_name":@"Ravenclaw",@"period_id":@29,@"period_name":@"6th Year"},
									@{@"school_class_id":@22,@"school_class_name":@"Hufflepuff",@"period_id":@28,@"period_name":@"5th Year"},
									@{@"school_class_id":@23,@"school_class_name":@"Hufflepuff",@"period_id":@29,@"period_name":@"6th Year"}
									]
							}
						  ];
	success(nil, response);
	//	HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
	//		NSLog(@"%@: %@", LOCALIZEDSTRING(@"EVALUATION_STUDENT_ERROR"), error);
	//	};
	//	NSString *path = [NSString stringWithFormat:@"%@/teacher/%@/teachings", [IOSRequest serverPath], [User sharedUser].userId];
	//	[IOSRequest requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self setupHandlers];
	[self setupTeachings];
	
	if ([[EGOCache globalCache] hasCacheForKey:CACHE_KEY]) {
		[self.tableView reloadData];
	} else {
		[self initAssessmentsByHTTPRequest];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([[User sharedUser].currentRole isEqualToString:UserRoleTeacher] && self.navigationController.navigationBar.topItem.rightBarButtonItems.count == 0) {
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(createAssessment)];
		[self.navigationController.navigationBar.topItem setRightBarButtonItem:editButton animated:NO];
	}
}

- (NSDictionary*)allowedTeachingsByPeriod {
	NSMutableDictionary *teachings = [NSMutableDictionary dictionary];
	
	NSEnumerator *disciplineEnumerator = [self.teachings keyEnumerator];
	CloudiversityDiscipline *discipline;
	while (discipline = [disciplineEnumerator nextObject]) {
		NSArray *classes = [self.teachings objectForKey:discipline];
		
		for (CloudiversityClass *currentClass in classes) {
			CloudiversityPeriod *classPeriod;
			if ((classPeriod = [self arrayOfPeriods:[teachings allKeys] getPeriod:currentClass.period])) {
				NSMutableDictionary *classesByDisciplines = ((NSDictionary*)[teachings objectForKey:classPeriod]).mutableCopy;
				
				NSMutableArray *classesByDiscipline = ((NSArray*)[classesByDisciplines objectForKey:discipline]).mutableCopy;
				if (classesByDiscipline) {
					[classesByDiscipline addObject:currentClass];
					[classesByDisciplines setObject:classesByDiscipline forKey:discipline];
				} else {
					[classesByDisciplines setObject:@[currentClass] forKey:discipline];
				}
				
				[teachings setObject:classesByDisciplines forKey:classPeriod];
			} else {
				[teachings setObject:@{discipline: @[currentClass]} forKey:currentClass.period];
			}
		}
	}
	
	return teachings;
}

- (CloudiversityPeriod*)arrayOfPeriods:(NSArray*)periods getPeriod:(CloudiversityPeriod*)period {
	for (CloudiversityPeriod *periodInArray in periods) {
		if ([periodInArray.periodID isEqualToNumber:period.periodID] &&
			[periodInArray.name isEqualToString:period.name]) {
			return periodInArray;
		}
	}
	return nil;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)createAssessment {
	EvaluationAssessmentsModificationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EvaluationAssessmentsModificationViewController"];
	
	vc.isCreatingAssessment = YES;
	vc.assessment = nil;
	vc.allowedTeachings = [self allowedTeachingsByPeriod];

	[self.navigationController pushViewController:vc animated:YES];
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
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld assessments", [self assessmentsForRow:[indexPath row] inDisciplines:disciplines].count];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self displinesInSection:section].count;;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"showAssessmentsSegue"]) {
		NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
		NSDictionary *disciplines = [self displinesInSection:[selectedRow section]];
		[((EvaluationAssessmentsViewController*)segue.destinationViewController) setAssessments:[self assessmentsForRow:[selectedRow row] inDisciplines:disciplines]];
		[((EvaluationAssessmentsViewController*)segue.destinationViewController) setDiscipline:[self disciplineForRow:[selectedRow row] inDisciplines:disciplines]];
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

- (NSArray*)assessmentsForRow:(NSInteger)row inDisciplines:(NSDictionary*)disciplines {
	__block NSArray *assessments = nil;
	__block NSInteger cnt = 0;
	[disciplines enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *obj, BOOL *stop) {
		if (cnt == row) {
			assessments = obj;
			*stop = YES;
		}
		cnt++;
	}];
	
	return assessments;
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
