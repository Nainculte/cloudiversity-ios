//
//  EvaluationAssessmentsModificationViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/01/2015.
//  Copyright (c) 2015 Cloudiversity. All rights reserved.
//

#import "EvaluationAssessmentsModificationViewController.h"
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import "CloudiversityAppDelegate.h"

#define PERIOD_TAG @"assessmentPeriod"
#define DISCIPLINE_TAG @"assessmentDiscipline"
#define CLASS_TAG @"assessmentClass"
#define STUDENT_TAG	@"assessmentStudent"

#define ASSESSMENT_TAG @"assessment"
#define ALL_CLASS_TAG @"assessmentForAllClass"

@interface EvaluationAssessmentsModificationViewController ()

@property (nonatomic, strong) CloudiversityPeriod *selectedPeriod;
@property (nonatomic, strong) CloudiversityDiscipline *selectedDiscipline;
@property (nonatomic, strong) CloudiversityClass *selectedClass;
@property (nonatomic, strong) CloudiversityStudent *selectedStudent;

@property (nonatomic, strong) NSArray *students;

@end

@implementation EvaluationAssessmentsModificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	if (!self.isCreatingAssessment) {
		[self initFormEdit];
	} else {
		[self initFormCreate];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (!self.isCreatingAssessment) {
		[self.navigationController.navigationBar.topItem setTitle:@"Edit"];
	} else {
		[self.navigationController.navigationBar.topItem setTitle:@"Add"];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Edit

- (void)initFormEdit {
	XLFormDescriptor *form;
	XLFormSectionDescriptor *section;
	XLFormRowDescriptor *row;
	
	form = [XLFormDescriptor formDescriptor];
	
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Assessment"];
	[form addFormSection:section];
	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:ASSESSMENT_TAG rowType:XLFormRowDescriptorTypeTextView];
	row.value = self.assessment.assessment;
	[section addFormRow:row];

	section = [XLFormSectionDescriptor formSection];
	[form addFormSection:section];
	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:ALL_CLASS_TAG rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"for all class"];
	row.value = self.assessment.isForAllClass;
	[section addFormRow:row];

	self.form = form;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(modifyAssessment)];
}

- (void)modifyAssessment {
	XLFormRowDescriptor *row;
	
	HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, id responseObject) {
		[DejalActivityView removeView];
		[((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];

		[self.navigationController popViewControllerAnimated:YES];
	};
	HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
		[DejalActivityView removeView];
		[((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
	};
	
	NSMutableDictionary *informations = [NSMutableDictionary dictionary];
	row = [self.form formRowWithTag:ASSESSMENT_TAG];
	[informations setObject:row.value forKey:@"assessment"];
	
	row = [self.form formRowWithTag:ALL_CLASS_TAG];
	[informations setObject:row.value forKey:@"school_class_assessment"];
	
	[[NetworkManager manager] updateAssessment:[self.assessment.assessmentID intValue] withInformations:informations onSuccess:success onFailure:failure];
	[DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading"].showNetworkActivityIndicator = YES;
}

#pragma mark - Create

- (void)initFormCreate {
	XLFormDescriptor *form;
	XLFormSectionDescriptor *section;
	XLFormRowDescriptor *row;
	
	form = [XLFormDescriptor formDescriptor];
	
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Assessment"];
	[form addFormSection:section];
	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:ASSESSMENT_TAG rowType:XLFormRowDescriptorTypeTextView];
	[section addFormRow:row];
	
	section = [XLFormSectionDescriptor formSection];
	[form addFormSection:section];
	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:ALL_CLASS_TAG rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"for all class"];
	[section addFormRow:row];
	
	// periods
	row = [XLFormRowDescriptor formRowDescriptorWithTag:PERIOD_TAG rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Period"];
	row.selectorOptions = [self periodNames];
	[section addFormRow:row];
	// disciplines
	row = [XLFormRowDescriptor formRowDescriptorWithTag:DISCIPLINE_TAG rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Discipline"];
	row.selectorOptions = nil;
	row.disabled = YES;
	[section addFormRow:row];
	// classes
	row = [XLFormRowDescriptor formRowDescriptorWithTag:CLASS_TAG rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Class"];
	row.selectorOptions = nil;
	row.disabled = YES;
	[section addFormRow:row];
	// students
	row = [XLFormRowDescriptor formRowDescriptorWithTag:STUDENT_TAG rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Student"];
	row.selectorOptions = @[@"Granger", @"Potter", @"Longbottom", @"And some others..."];
	[section addFormRow:row];
	row.selectorOptions = nil;
	row.disabled = YES;
	
	form.delegate = self;
	self.form = form;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(createAssessment)];
}

- (void)createAssessment {
	NSNumber *isForAllClass = ([self.form formRowWithTag:ALL_CLASS_TAG].value == nil ? @NO : [self.form formRowWithTag:ALL_CLASS_TAG].value);

	if (!self.selectedPeriod && !self.selectedDiscipline && !self.selectedClass)
		return;
	if (![isForAllClass boolValue] && !self.selectedStudent)
		return;

	id studentID = self.selectedStudent.studentID;
	
	NSMutableDictionary *assessmentInfo = [NSMutableDictionary dictionary];

	[assessmentInfo setObject:[self.form formRowWithTag:ASSESSMENT_TAG].value forKey:@"assessment"];
	[assessmentInfo setObject:self.selectedDiscipline.disciplineID forKey:@"discipline_id"];
	[assessmentInfo setObject:self.selectedClass.schoolClassId forKey:@"school_class_id"];
	[assessmentInfo setObject:self.selectedPeriod.periodID forKey:@"period_id"];
	[assessmentInfo setObject:isForAllClass forKey:@"school_class_assessment"];
	if (studentID) {
		[assessmentInfo setObject:studentID forKey:@"student_id"];
	}

	NSDictionary *newAssessment = @{@"grade_assessment": assessmentInfo};
	
	
	HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, id responseObject) {
		[DejalActivityView removeView];
		[((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];

		[self.navigationController popViewControllerAnimated:YES];
		[self.assessmentsVC reloadAssessments];
	};
	HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
		[DejalActivityView removeView];
		[((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
		
		NSLog(@"%@", error);
	};
	[[NetworkManager manager] requestPostToPath:@"/evaluations/assessments" withParams:newAssessment onSuccess:success onFailure:failure];
	[DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading"].showNetworkActivityIndicator = YES;
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow
								oldValue:(id)oldValue
								newValue:(id)newValue {
	XLFormRowDescriptor *row;
	
	if ([formRow.tag isEqualToString:ALL_CLASS_TAG]) {
		row = [self.form formRowWithTag:STUDENT_TAG];
		if ([((NSNumber*)formRow.value) boolValue]) {
			row.selectorOptions = nil;
			row.value = nil;
			row.disabled = YES;
			[self reloadFormRow:row];
			self.selectedStudent = nil;
		} else {
			if (self.selectedClass) {
				row.disabled = NO;
				row.selectorOptions = [self classNamesForSelectedDisciplineAndPeriod];
				row.value = self.selectedStudent.name;
				[self reloadFormRow:row];
			}
		}

	} else if ([formRow.tag isEqualToString:PERIOD_TAG]) {
		self.selectedPeriod = [self periodForName:formRow.value];
		row = [self.form formRowWithTag:DISCIPLINE_TAG];
		row.selectorOptions = [self disciplineNamesForSelectedPeriod];
		row.disabled = NO;
		[self reloadFormRow:row];
		self.selectedDiscipline = nil;
		
		row = [self.form formRowWithTag:CLASS_TAG];
		row.selectorOptions = nil;
		row.value = nil;
		row.disabled = YES;
		[self reloadFormRow:row];
		self.selectedClass = nil;
		
		row = [self.form formRowWithTag:STUDENT_TAG];
		row.value = nil;
		row.disabled = YES;
		[self reloadFormRow:row];
		self.selectedStudent = nil;
	} else if ([formRow.tag isEqualToString:DISCIPLINE_TAG] && ![newValue isKindOfClass:[NSNull class]]) {
		self.selectedDiscipline = [self disciplineForName:formRow.value];
		row = [self.form formRowWithTag:CLASS_TAG];
		row.selectorOptions = [self classNamesForSelectedDisciplineAndPeriod];
		row.disabled = NO;
		[self reloadFormRow:row];
		self.selectedClass = nil;
		
		row = [self.form formRowWithTag:STUDENT_TAG];
		row.value = nil;
		row.disabled = YES;
		[self reloadFormRow:row];
		self.selectedStudent = nil;
	} else if ([formRow.tag isEqualToString:CLASS_TAG] && ![newValue isKindOfClass:[NSNull class]]) {
		self.selectedClass = [self classForName:formRow.value];
		[self initStudentNames];
	} else if ([formRow.tag isEqualToString:STUDENT_TAG] && ![newValue isKindOfClass:[NSNull class]]) {
		for (CloudiversityStudent *student in self.students) {
			if ([student.name isEqualToString:([self.form formRowWithTag:STUDENT_TAG].value)]) {
				self.selectedStudent = student;
				break;
			}
		}
	}
}

#pragma mark - helpers

- (NSArray*)periodNames {
	NSMutableArray *names = [NSMutableArray array];
	
	NSArray *periods = [self.allowedTeachings allKeys];
	for (CloudiversityPeriod *period in periods) {
		[names addObject:period.name];
	}
	
	return names.copy;
}

- (NSArray*)disciplineNamesForSelectedPeriod {
	NSMutableArray *names = [NSMutableArray array];
	
	NSArray *disciplines = [[self.allowedTeachings objectForKey:self.selectedPeriod] allKeys];
	for (CloudiversityDiscipline *discipline in disciplines) {
		[names addObject:discipline.name];
	}
	
	return names.copy;
}

- (NSArray*)classNamesForSelectedDisciplineAndPeriod {
	NSMutableArray *names = [NSMutableArray array];
	
	NSArray *classes = [[self.allowedTeachings objectForKey:self.selectedPeriod] objectForKey:self.selectedDiscipline];
	for (CloudiversityClass *classe in classes) {
		[names addObject:classe.schoolClassName];
	}
	
	return names.copy;
}

- (CloudiversityPeriod*)periodForName:(NSString*)name {
	NSArray *periods = [self.allowedTeachings allKeys];
	
	for (CloudiversityPeriod *period in periods) {
		if ([period.name isEqualToString:name]) {
			return period;
		}
	}
	
	return nil;
}

- (CloudiversityDiscipline*)disciplineForName:(NSString*)name {
	NSArray *disciplines = [[self.allowedTeachings objectForKey:self.selectedPeriod] allKeys];
	
	for (CloudiversityDiscipline *discipline in disciplines) {
		if ([discipline.name isEqualToString:name]) {
			return discipline;
		}
	}
	
	return nil;
}

- (CloudiversityClass*)classForName:(NSString*)name {
	NSArray *classes = [[self.allowedTeachings objectForKey:self.selectedPeriod] objectForKey:self.selectedDiscipline];
	
	for (CloudiversityClass *classe in classes) {
		if ([classe.schoolClassName isEqualToString:name]) {
			return classe;
		}
	}
	
	return nil;
}

- (void)initStudentNames {
	HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, NSArray *students) {
		NSMutableArray *newStudents = [NSMutableArray array];
		NSMutableArray *studentNames = [NSMutableArray array];
		for (NSDictionary *student in students) {
			CloudiversityStudent *newStudent = [CloudiversityStudent fromJSON:student];
			[newStudents addObject:newStudent];
			[studentNames addObject:newStudent.name];
		}
		
		self.students = newStudents;
		
		XLFormRowDescriptor *row = [self.form formRowWithTag:STUDENT_TAG];
		row.selectorOptions = studentNames;

		if (![self.form formRowWithTag:ALL_CLASS_TAG].value ||
			![[self.form formRowWithTag:ALL_CLASS_TAG].value boolValue]) {
			row.disabled = NO;
		} else {
			row.disabled = YES;
		}
		[self reloadFormRow:row];
	};
	HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@", error);
	};
	NSString *path = [NSString stringWithFormat:@"/school_class/%@/students", self.selectedClass.schoolClassId];
	[[NetworkManager manager] requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
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
