//
//  EvaluationViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 05/09/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "EvaluationAllGradesViewController.h"
#import "EvaluationGradesViewController.h"
#import "EvaluationGradeModificationViewController.h"

#define CACHE_KEY	@"gradesStudentList"
#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"EvaluationVC"]

@interface EvaluationAllGradesViewController ()

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;
@property (nonatomic, strong) NSDictionary *teachings;

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

- (void)setupTeachings {
	HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, NSArray *response) {
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
	
	HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@: %@", LOCALIZEDSTRING(@"EVALUATION_STUDENT_ERROR"), error);
	};
	NSString *path = [NSString stringWithFormat:@"/teacher/%@/teachings", [User sharedUser].userId];
	[[NetworkManager manager] requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[self setupHandlers];
	[self setupTeachings];

	[self initAssessmentsByHTTPRequest];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([[User sharedUser].currentRole isEqualToString:UserRoleTeacher]) {
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(createGrade)];
		[self.navigationController.navigationBar.topItem setRightBarButtonItem:editButton animated:NO];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadgrades {
	[self initAssessmentsByHTTPRequest];
}

#pragma mark - creation grade

- (void)createGrade {
	EvaluationGradeModificationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EvaluationGradeModificationViewController"];
	
	vc.isCreatingGrade = YES;
	vc.grade = nil;
	vc.allowedTeachings = [self allowedTeachingsByPeriod];
	vc.gradeVC = self;
	
	[self.navigationController pushViewController:vc animated:YES];
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
