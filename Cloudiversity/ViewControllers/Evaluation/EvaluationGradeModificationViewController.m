//
//  EvaluationGradeModificationViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/01/2015.
//  Copyright (c) 2015 Cloudiversity. All rights reserved.
//

#import "EvaluationGradeModificationViewController.h"
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import "CloudiversityAppDelegate.h"

#define BSELF(ptr) __weak typeof(ptr) bself = ptr;

#define PERIOD_TAG @"gradePeriod"
#define DISCIPLINE_TAG @"gradeDiscipline"
#define CLASS_TAG @"gradeClass"
#define STUDENT_TAG	@"gradeStudent"

#define NOTE_TAG 	@"gradeNote"
#define COEF_TAG	@"gradeCoef"
#define DESC_TAG	@"gradeAssessment"

@interface EvaluationGradeModificationViewController ()

@property (nonatomic, strong) CloudiversityPeriod *selectedPeriod;
@property (nonatomic, strong) CloudiversityDiscipline *selectedDiscipline;
@property (nonatomic, strong) CloudiversityClass *selectedClass;
@property (nonatomic, strong) CloudiversityStudent *selectedStudent;

@property (nonatomic, strong) NSArray *students;

@end

@implementation EvaluationGradeModificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	if (!self.isCreatingGrade) {
		[self initFormEdit];
	} else {
		[self initFormCreate];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (!self.isCreatingGrade) {
		[self.navigationController.navigationBar.topItem setTitle:@"Edit"];
	} else {
		[self.navigationController.navigationBar.topItem setTitle:@"Add"];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Edit Grade

- (void)initFormEdit {
	XLFormDescriptor *form;
	XLFormSectionDescriptor *section;
	XLFormRowDescriptor *row;
	
	form = [XLFormDescriptor formDescriptor];
	
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Note et Coefficient"];
	[form addFormSection:section];	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:NOTE_TAG rowType:XLFormRowDescriptorTypeNumber title:@"Note"];
	[row setValue:self.grade.note];
	[section addFormRow:row];
	row = [XLFormRowDescriptor formRowDescriptorWithTag:COEF_TAG rowType:XLFormRowDescriptorTypeNumber title:@"Coefficient"];
	[row setValue:self.grade.coefficent];
	[section addFormRow:row];

	section = [XLFormSectionDescriptor formSectionWithTitle:@"Commentaire"];
	[form addFormSection:section];
	row = [XLFormRowDescriptor formRowDescriptorWithTag:DESC_TAG rowType:XLFormRowDescriptorTypeTextView];
	[row setValue:self.grade.assessment];
	[section addFormRow:row];

	self.form = form;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(modifyGrade)];
}

- (void)modifyGrade {
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
	row = [self.form formRowWithTag:NOTE_TAG];
	[informations setObject:row.value forKey:@"note"];

	row = [self.form formRowWithTag:COEF_TAG];
	[informations setObject:row.value forKey:@"coefficient"];

	row = [self.form formRowWithTag:DESC_TAG];
	[informations setObject:row.value forKey:@"assessment"];

	[[NetworkManager manager] updateGrade:[self.grade.gradeID intValue] withInformations:informations onSuccess:success onFailure:failure];
	[DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading"].showNetworkActivityIndicator = YES;
}

#pragma mark - Create Grade

- (void)initFormCreate {
	XLFormDescriptor *form;
	XLFormSectionDescriptor *section;
	XLFormRowDescriptor *row;
	
	form = [XLFormDescriptor formDescriptor];

	section = [XLFormSectionDescriptor formSection];
	[form addFormSection:section];
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
	row.selectorOptions = nil;
	row.disabled = YES;
	[section addFormRow:row];
	
	
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Note et Coefficient"];
	[form addFormSection:section];
	row = [XLFormRowDescriptor formRowDescriptorWithTag:NOTE_TAG rowType:XLFormRowDescriptorTypeNumber title:@"Note"];
	[section addFormRow:row];
	row = [XLFormRowDescriptor formRowDescriptorWithTag:COEF_TAG rowType:XLFormRowDescriptorTypeNumber title:@"Coefficient"];
	[section addFormRow:row];
	
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Commentaire"];
	[form addFormSection:section];
	row = [XLFormRowDescriptor formRowDescriptorWithTag:DESC_TAG rowType:XLFormRowDescriptorTypeTextView];
	[section addFormRow:row];
	
	form.delegate = self;
	self.form = form;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(createGrade)];
}

/*
 {
	 "grade_grade":{
		 "assessment":string,
		 "note":integer,
		 "coefficient":integer,
		 "discipline_id":integer,
		 "school_class_id":integer,
		 "period_id":integer,
		 "student_id":integer,
	 }
 }
 */
- (void)createGrade {
#warning TODO
	NSDictionary *newGrade = @{
							   @"grade_grade": @{
									   @"assessment": (NSString*)[self.form formRowWithTag:DESC_TAG].value,
									   @"note": [self.form formRowWithTag:NOTE_TAG].value,
									   @"coefficient": [self.form formRowWithTag:COEF_TAG].value,
									   @"discipline_id": self.selectedDiscipline.disciplineID,
									   @"school_class_id": self.selectedClass.schoolClassId,
									   @"period_id": self.selectedPeriod.periodID,
									   @"student_id": self.selectedStudent.studentID
									   }
							   };
	
	
	HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, id responseObject) {
		[DejalActivityView removeView];
		[((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
		
		[self.navigationController popViewControllerAnimated:YES];
	};
	HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
		[DejalActivityView removeView];
		[((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
		
		NSLog(@"%@", error);
	};
	[[NetworkManager manager] requestPostToPath:@"/evaluations/grades" withParams:newGrade onSuccess:success onFailure:failure];
	[DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading"].showNetworkActivityIndicator = YES;
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow
								oldValue:(id)oldValue
								newValue:(id)newValue {
	XLFormRowDescriptor *row;
	
	if ([formRow.tag isEqualToString:PERIOD_TAG] && ![newValue isKindOfClass:[NSNull class]]) {
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
#warning TOCHECK
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
		row.disabled = NO;
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
