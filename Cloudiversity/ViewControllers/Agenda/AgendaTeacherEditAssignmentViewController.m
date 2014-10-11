//
//  AgendaTeacherEditAssignmentViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 22/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaTeacherEditAssignmentViewController.h"
#import "AgendaTeacherClassViewController.h"
#import "AgendaAssignment.h"
#import "IOSRequest.h"
#import "CloudDateConverter.h"
#import "DejalActivityView.h"
#import "CloudiversityAppDelegate.h"

#import "CloudLogoCell.h"
#import "CloudURLCellPicker.h"

@interface AgendaTeacherEditAssignmentViewController ()

@end

@implementation AgendaTeacherEditAssignmentViewController

- (id)initWithDisciplineID:(int)disciplineID withClassID:(int)classID andAssignment:(AgendaAssignment *)assignment presenter:(AgendaTeacherClassViewController *)presenter
{
    self.disciplineID = disciplineID;
    self.classID = classID;
    self.assignment = assignment;
    self.presenter = presenter;
    return [self init];
}

- (id)init
{
    AgendaTeacherEditFormViewController *vc;
    if (self.assignment) {
        vc = [[AgendaTeacherEditFormViewController alloc] initEdit];
    } else {
        vc = [[AgendaTeacherEditFormViewController alloc] initAdd];
    }
    vc.assignment = self.assignment;
    vc.disciplineID = self.disciplineID;
    vc.classID = self.classID;
    vc.superPresenter = self.presenter;
    [vc postInit];
    self = [super initWithRootViewController:vc];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.navigationBar setBarTintColor:[UIColor cloudLightBlue]];
    self.navigationBar.tintColor = [UIColor whiteColor];
}

- (void) viewWillUnload
{
    ((AgendaTeacherClassViewController *)self.presentingViewController).editedAssignment = self.assignment;
    [super viewWillUnload];
}

@end

@interface AgendaTeacherEditFormViewController ()

@end


@implementation AgendaTeacherEditFormViewController

static NSString *titleTag = @"Title";
static NSString *timePrecisedTag = @"Timeprecised";
static NSString *dueDateTag = @"DueDate";
static NSString *descriptionTag = @"Description";

- (void)postInit
{
    XLFormRowDescriptor * row;
    if (self.assignment) {
        row = [self.form formRowWithTag:titleTag];
        row.value = self.assignment.title;

        row = [self.form formRowWithTag:timePrecisedTag];
        XLFormDateCell *dueDate = (XLFormDateCell *)[[self.form formRowWithTag:dueDateTag] cellForFormController:self];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if (self.assignment.timePrecised) {
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dueDate setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
            row.value = [NSNumber numberWithBool:YES];
        } else {
            [dateFormatter setDateStyle:NSDateFormatterLongStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dueDate setFormDatePickerMode:XLFormDateDatePickerModeDate];
            row.value = [NSNumber numberWithBool:NO];
        }
        dueDate.dateFormatter = dateFormatter;
        row = [self.form formRowWithTag:dueDateTag];
        row.value = self.assignment.dueDate;
        [dueDate update];

        row = [self.form formRowWithTag:descriptionTag];
        row.value = self.assignment.assignmentDescription;
    }
}

- (id)init
{
    self = [super init];
    return self;
}

- (id)initAdd
{
    self = [self init];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAdd)];
    [self initFormWithTitle:@"Add" andrightBarButtonItem:button];
    return self;
}

- (id)initEdit
{
    self = [self init];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveEdit)];
    [self initFormWithTitle:@"Edit" andrightBarButtonItem:button];
    return self;
}

- (void)initFormWithTitle:(NSString *)title andrightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
{
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    form = [XLFormDescriptor formDescriptorWithTitle:title];

    //Title
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:titleTag rowType:XLFormRowDescriptorTypeText title:@"Title"];
    row.required = YES;
    [section addFormRow:row];

    //Due Date
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Due Date"];
    [form addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:timePrecisedTag rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Time precised"];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:dueDateTag rowType:XLFormRowDescriptorTypeDateInline title:@"Due date"];
    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [section addFormRow:row];

    //description
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:descriptionTag rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Description" forKey:@"textView.placeholder"];
    row.required = YES;
    [section addFormRow:row];

    self.form = form;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    if ([formRow.tag isEqualToString:timePrecisedTag]) {
        XLFormDateCell *dueDate = (XLFormDateCell *)[[self.form formRowWithTag:dueDateTag] cellForFormController:self];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if ([[formRow.value valueData] boolValue] == YES) {
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dueDate setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
        } else {
            [dateFormatter setDateStyle:NSDateFormatterLongStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dueDate setFormDatePickerMode:XLFormDateDatePickerModeDate];
        }
        dueDate.dateFormatter = dateFormatter;
        [dueDate update];
    }
}

- (void)cancel
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveAdd
{
    [self.view endEditing:YES];
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [self showFormValidationError:[validationErrors firstObject]];
        return;
    }
    [self.tableView endEditing:YES];

    //send a request, add it to assignment list
    XLFormRowDescriptor *row;

    row = [self.form formRowWithTag:titleTag];
    NSString *title = row.value;

    row = [self.form formRowWithTag:dueDateTag];
    NSDate *duedate = row.value;
    NSString *date = [[CloudDateConverter sharedMager] stringFromDate:duedate];

    row = [self.form formRowWithTag:timePrecisedTag];
    bool timePrecised = [row.value boolValue];
    NSString *time = nil;
    if (timePrecised) {
        time = [[CloudDateConverter sharedMager] stringFromTime:duedate];
    }

    row = [self.form formRowWithTag:descriptionTag];
    NSString *description = row.value;

    BSELF(self)
    HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        NSDate *date;
        if ([response objectForKey:@"duetime"] != [NSNull null]) {
            date = [[CloudDateConverter sharedMager] dateAndTimeFromString:[NSString stringWithFormat:@"%@ %@", response[@"deadline"], response[@"duetime"]]];
        } else {
            date = [[CloudDateConverter sharedMager] dateFromString:response[@"deadline"]];
        }
        bself.assignment = [[AgendaAssignment alloc] initWithTitle:response[@"title"]
                                                            withId:[response[@"id"] intValue]
                                                           dueTime:date
                                                      timePrecised:[response objectForKey:@"duetime"] == [NSNull null] ? NO : YES
                                                       description:response[@"wording"]
                                                  withCreationDate:[[CloudDateConverter sharedMager] dateAndTimeFromString:response[@"created_at"]]
                                                     andLastUpdate:[[CloudDateConverter sharedMager] dateAndTimeFromString:response[@"updated_at"]]
                                                     forDissipline:response[@"discipline"]
                                                           inClass:response[@"school_class"]];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
        [bself dismissViewControllerAnimated:YES completion:^{
            [bself.superPresenter.assignments addObject:self.assignment];
            [bself.superPresenter.tableView reloadData];
        }];
    };

    HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", operation.response);
        switch (operation.response.statusCode) {
            default:
                break;
        }
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };

    [IOSRequest postAssignmentWithTitle:title
                            withDueDate:date
                            withDueTime:time
                        withDescription:description
                       withDisciplineID:self.disciplineID
                            withClassID:self.classID
                              onSuccess:success
                              onFailure:failure];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
}

- (void)saveEdit
{
    [self.view endEditing:YES];
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [self showFormValidationError:[validationErrors firstObject]];
        return;
    }
    [self.tableView endEditing:YES];

    //send a request, add it to assignment list
    XLFormRowDescriptor *row;

    row = [self.form formRowWithTag:titleTag];
    NSString *title = row.value;

    row = [self.form formRowWithTag:dueDateTag];
    NSDate *duedate = row.value;
    NSString *date = [[CloudDateConverter sharedMager] stringFromDate:duedate];

    row = [self.form formRowWithTag:timePrecisedTag];
    bool timePrecised = [row.value boolValue];
    NSString *time = nil;
    if (timePrecised) {
        time = [[CloudDateConverter sharedMager] stringFromTime:duedate];
    }

    row = [self.form formRowWithTag:descriptionTag];
    NSString *description = row.value;

    BSELF(self)
    HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        NSDate *date;
        if ([response objectForKey:@"duetime"] != [NSNull null]) {
            date = [[CloudDateConverter sharedMager] dateAndTimeFromString:[NSString stringWithFormat:@"%@ %@", response[@"deadline"], response[@"duetime"]]];
        } else {
            date = [[CloudDateConverter sharedMager] dateFromString:response[@"deadline"]];
        }
        bself.assignment = [[AgendaAssignment alloc] initWithTitle:response[@"title"]
                                                            withId:[response[@"id"] intValue]
                                                           dueTime:date
                                                      timePrecised:[response objectForKey:@"duetime"] == [NSNull null] ? NO : YES
                                                       description:response[@"wording"]
                                                  withCreationDate:[[CloudDateConverter sharedMager] dateAndTimeFromString:response[@"created_at"]]
                                                     andLastUpdate:[[CloudDateConverter sharedMager] dateAndTimeFromString:response[@"updated_at"]]
                                                     forDissipline:response[@"discipline"]
                                                           inClass:response[@"school_class"]];
//        bself.assignment.title = response[@"title"];
//        bself.assignment.dueDate = date;
//        bself.assignment.timePrecised = [response objectForKey:@"duetime"] == [NSNull null] ? NO : YES;
//        bself.assignment.assignmentDescription = response[@"wording"];
//        bself.assignment.lastUpdate = [[CloudDateConverter sharedMager] dateAndTimeFromString:response[@"updated_at"]];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
        [bself dismissViewControllerAnimated:YES completion:^{
            [bself.superPresenter.assignments addObject:self.assignment];
            [bself.superPresenter.tableView reloadData];
        }];
    };

    HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", operation.response);
        switch (operation.response.statusCode) {
            default:
                break;
        }
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };

    [IOSRequest patchAssignmentWithTitle:title
                             withDueDate:date
                             withDueTime:time
                         withDescription:description
                        withDisciplineID:self.disciplineID
                             withClassID:self.classID
                         andAssignmentID:self.assignment.assignmentId
                               onSuccess:success
                               onFailure:failure];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
}

- (NSArray *)formValidationErrors
{
    NSMutableArray *result = [NSMutableArray array];
    NSError *error;
    XLFormRowDescriptor *row = [self.form formRowWithTag:titleTag];
    if ((error = [[row cellForFormController:self] formDescriptorCellLocalValidation])) {
        [result addObject:error];
    }
    row = [self.form formRowWithTag:descriptionTag];
    row.title = @"Description";
    if ((error = [[row cellForFormController:self] formDescriptorCellLocalValidation])) {
        [result addObject:error];
    }
    row.title = @"";
    return result;
}

-(void)showFormValidationError:(NSError *)error
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

@end