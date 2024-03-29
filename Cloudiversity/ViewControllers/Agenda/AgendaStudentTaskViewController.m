//
//  AgendaStudentTaskViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaStudentTaskViewController.h"
#import "UICloud.h"
#import "CloudDateConverter.h"
#import "AMPieChartView.h"
#import "UIColor+Cloud.h"
#import "NetworkManager.h"
#import "DejalActivityView.h"

#define DICO_ID					@"id"
#define DICO_TITLE				@"title"
#define DICO_PROGRESS			@"progress"
#define DICO_DEADLINE			@"deadline"
#define DICO_DUETIME 			@"duetime"
#define DICO_WORDING 			@"wording" // This is the description of the assignment
#define DICO_CREATED_AT 		@"created_at"
#define DICO_UPDATE_AT 			@"updated_at"
#define DICO_DISCIPLINE 		@"discipline"
#define DICO_DISCIPLINE_ID			@"id"
#define DICO_DISCIPLINE_NAME		@"name"
#define DICO_SCHOOL_CLASS 		@"school_class"
#define DICO_SCHOOL_CLASS_ID		@"id"
#define DICO_SCHOOL_CLASS_NAME		@"name"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"AgendaStudentVC"]

@interface AgendaStudentTaskViewController ()

@property (weak, nonatomic) IBOutlet CloudLabel *workTitleLabel;
@property (weak, nonatomic) IBOutlet AMPieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet CloudLabel *givenOnLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *givenDateLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *dueToLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *dueToDateLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *dissiplineNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *assignmentDescriptionTextView;
@property (weak, nonatomic) IBOutlet UISlider *progressBarInput;

@property (nonatomic, strong) AgendaAssignment *assignment;

@end

@implementation AgendaStudentTaskViewController

#pragma mark - View life
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initAssignment];
	
	[self.pieChartView setInternalColor:[UIColor cloudLightBlue]];
	[self.pieChartView setExternalColor:[UIColor cloudBlue]];
	[self.workTitleLabel setFont:[UIFont fontWithName:CLOUD_FONT_BOLD size:self.workTitleLabel.font.pointSize]];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.givenOnLabel.text = LOCALIZEDSTRING(@"TASK_GIVEN_ON");
    self.dueToLabel.text = LOCALIZEDSTRING(@"TASK_DUE_TO");
}

- (void)viewWillDisappear:(BOOL)animated {
	void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *response = (NSDictionary*)responseObject;
		
		self.pieChartView.percentage = [response[DICO_PROGRESS] integerValue];
		self.assignment.progress = [response[DICO_PROGRESS] integerValue];
		[self.progressBarInput setValue:[response[DICO_PROGRESS] integerValue]];
		[self.dataSource assignmentProgressUpdated:self.assignment];
        [DejalActivityView removeView];
	};
	void (^failure)(AFHTTPRequestOperation *, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"AGENDA_STUDENT_ERROR")
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
	};
	if (self.progressBarInput.value != self.assignment.progress) {
		[DejalActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"AGENDA_STUDENT_LOADING")].showNetworkActivityIndicator = YES;
		[[NetworkManager manager] updateAssignmentWithId:self.assignment.assignmentId withProgression:self.progressBarInput.value onSuccess:success onFailure:failure];
	}
	
	[super viewWillDisappear:animated];
}

#pragma mark - Assignment initialization

#define SAVING_PLACE_ASSIGNMENT	@"agendaTmpPlaceForAssignment"

- (void)initAssignment {
	self.assignment = [self.dataSource getSelectedAssignment];
	
	void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *response = (NSDictionary *)responseObject;

		self.assignment.progress = [response[DICO_PROGRESS] integerValue];
		self.assignment.assignmentDescription = response[DICO_WORDING];
		self.assignment.creationDate = [[CloudDateConverter sharedMager] dateAndTimeFromString:response[DICO_CREATED_AT]];
		if (self.assignment.creationDate == nil)
			self.assignment.creationDate = [[CloudDateConverter sharedMager] dateAndTimeWithSecondsFromString:response[DICO_CREATED_AT]];
		self.assignment.lastUpdate = [[CloudDateConverter sharedMager] dateAndTimeFromString:response[DICO_UPDATE_AT]];
		if (self.assignment.lastUpdate == nil)
			self.assignment.lastUpdate = [[CloudDateConverter sharedMager] dateAndTimeWithSecondsFromString:response[DICO_UPDATE_AT]];
		
		self.workTitleLabel.text = self.assignment.title;
		self.assignmentDescriptionTextView.text = self.assignment.assignmentDescription;
		self.pieChartView.percentage = self.assignment.progress;
		if ([[[CloudDateConverter sharedMager] stringFromTime:self.assignment.dueDate] isEqualToString:[CloudDateConverter nullTime]]) {
			self.dueToDateLabel.text = [[CloudDateConverter sharedMager] stringFromFullDate:self.assignment.dueDate];
		} else {
			self.dueToDateLabel.text = [[CloudDateConverter sharedMager] stringFromFullDateAtTime:self.assignment.dueDate];
		}
		self.givenDateLabel.text = [[CloudDateConverter sharedMager] stringFromFullDateAtTime:self.assignment.creationDate];
		self.dissiplineNameLabel.text = (self.assignment.dissiplineInformation)[DICO_DISCIPLINE_NAME];
		
		[self.progressBarInput setValue:self.assignment.progress];
		[self.progressBarInput addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [DejalActivityView removeView];
	};
	void (^failure)(AFHTTPRequestOperation *, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"AGENDA_STUDENT_ERROR")
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
	};
    [DejalBezelActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"AGENDA_STUDENT_LOADING")].showNetworkActivityIndicator = YES;
	[[NetworkManager manager] getAssignmentInformation:self.assignment.assignmentId onSuccess:success onFailure:failure];
}

#pragma mark - PieChart update
- (void)sliderValueChanged:(UISlider*)slider {
	self.pieChartView.percentage = slider.value;
}

@end
