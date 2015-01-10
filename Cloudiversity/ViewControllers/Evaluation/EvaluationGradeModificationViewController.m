//
//  EvaluationGradeModificationViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/01/2015.
//  Copyright (c) 2015 Cloudiversity. All rights reserved.
//

#import "EvaluationGradeModificationViewController.h"
#import "IOSRequest.h"
#import "DejalActivityView.h"
#import "CloudiversityAppDelegate.h"

#define BSELF(ptr) __weak typeof(ptr) bself = ptr;

#define STUDENT_TAG	@"gradeStudent"
#define NOTE_TAG 	@"gradeNote"
#define COEF_TAG	@"gradeCoef"
#define DESC_TAG	@"gradeAssessment"

@interface EvaluationGradeModificationViewController ()

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

	[IOSRequest updateGrade:[self.grade.gradeID intValue] withInformations:informations onSuccess:success onFailure:failure];
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
	row = [XLFormRowDescriptor formRowDescriptorWithTag:STUDENT_TAG rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Student"];
	row.selectorOptions = @[@"Granger", @"Potter", @"Longbottom", @"And some others..."];
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
	
	self.form = form;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(createGrade)];
}

- (void)createGrade {
	
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
