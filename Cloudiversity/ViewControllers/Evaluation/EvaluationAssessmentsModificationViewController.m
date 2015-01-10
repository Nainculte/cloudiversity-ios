//
//  EvaluationAssessmentsModificationViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/01/2015.
//  Copyright (c) 2015 Cloudiversity. All rights reserved.
//

#import "EvaluationAssessmentsModificationViewController.h"
#import "IOSRequest.h"
#import "DejalActivityView.h"
#import "CloudiversityAppDelegate.h"

#define ASSESSMENT_TAG @"assessment"
#define ALL_CLASS_TAG @"assessmentForAllClass"
#define STUDENT_TAG @"assessmentForStudent"

@interface EvaluationAssessmentsModificationViewController ()

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
	
	[IOSRequest updateAssessment:[self.assessment.assessmentID intValue] withInformations:informations onSuccess:success onFailure:failure];
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
	row = [XLFormRowDescriptor formRowDescriptorWithTag:STUDENT_TAG rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Student"];
	row.selectorOptions = @[@"Granger", @"Potter", @"Longbottom", @"And some others..."];
	[section addFormRow:row];
	
	self.form = form;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(createAssessment)];
}

- (void)createAssessment {
	
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
