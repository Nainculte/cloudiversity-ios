//
//  AgendaTeacherEditAssignmentViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 22/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaTeacherEditAssignmentViewController.h"
#import "CloudDateConverter.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"AgendaTeacherVC"]

#pragma mark - AgendaTeacherEditAssignmentViewController
@interface AgendaTeacherEditAssignmentViewController ()

@end

@implementation AgendaTeacherEditAssignmentViewController

#pragma mark - AgendaTeacherEditAssignmentViewController Initilization
- (instancetype)initWithDisciplineID:(NSInteger)disciplineID withClassID:(NSInteger)classID andAssignment:(AgendaAssignment *)assignment presenter:(AgendaTeacherClassViewController *)presenter
{
    self.disciplineID = disciplineID;
    self.classID = classID;
    self.assignment = assignment;
    self.presenter = presenter;
    return [self init];
}

- (instancetype)init
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

#pragma mark - View life cycle
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
    [super viewDidUnload];
}

@end

#pragma mark - AgendaTeacherEditFormViewController
@interface AgendaTeacherEditFormViewController ()

@end


@implementation AgendaTeacherEditFormViewController

#pragma mark - Constants
static NSString *titleTag = @"Title";
static NSString *timePrecisedTag = @"Timeprecised";
static NSString *dueDateTag = @"DueDate";
static NSString *descriptionTag = @"Description";

#pragma mark Initializers
- (instancetype)initAdd
{
    self = [self init];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAdd)];
    [self initFormWithTitle:LOCALIZEDSTRING(@"ADD") andrightBarButtonItem:button];
    return self;
}

- (instancetype)initEdit
{
    self = [self init];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveEdit)];
    [self initFormWithTitle:LOCALIZEDSTRING(@"EDIT") andrightBarButtonItem:button];
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

    row = [XLFormRowDescriptor formRowDescriptorWithTag:titleTag rowType:XLFormRowDescriptorTypeText title:LOCALIZEDSTRING(@"TITLE")];
    row.required = YES;
    [section addFormRow:row];

    //Due Date
    section = [XLFormSectionDescriptor formSectionWithTitle:LOCALIZEDSTRING(@"DUE_DATE")];
    [form addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:timePrecisedTag rowType:XLFormRowDescriptorTypeBooleanSwitch title:LOCALIZEDSTRING(@"TIME_PRECISED")];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:dueDateTag rowType:XLFormRowDescriptorTypeDateInline title:LOCALIZEDSTRING(@"DUE_DATE")];
    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [section addFormRow:row];

    //description
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:descriptionTag rowType:XLFormRowDescriptorTypeTextView];
    (row.cellConfigAtConfigure)[@"textView.placeholder"] = LOCALIZEDSTRING(@"DESCRIPTION");
    row.required = YES;
    [section addFormRow:row];

    self.form = form;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

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
            row.value = @YES;
        } else {
            [dateFormatter setDateStyle:NSDateFormatterLongStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dueDate setFormDatePickerMode:XLFormDateDatePickerModeDate];
            row.value = @NO;
        }
        dueDate.dateFormatter = dateFormatter;
        row = [self.form formRowWithTag:dueDateTag];
        row.value = self.assignment.dueDate;
        [dueDate update];

        row = [self.form formRowWithTag:descriptionTag];
        row.value = self.assignment.assignmentDescription;
    }
}

#pragma mark - Form methods
- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    if ([formRow.tag isEqualToString:timePrecisedTag]) {
        XLFormDateCell *dueDate = (XLFormDateCell *)[[self.form formRowWithTag:dueDateTag] cellForFormController:self];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if ([[formRow.value valueData] boolValue]) {
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
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"AGENDA_TEACHER_ERROR") message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Actions
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
    NSDate *dueDate = row.value;

    row = [self.form formRowWithTag:timePrecisedTag];
    bool timePrecised = [row.value boolValue];

    row = [self.form formRowWithTag:descriptionTag];
    NSString *description = row.value;

    AgendaAssignment *assignment = [[AgendaAssignment alloc] initWithTitle:title
                                                                    withId:0
                                                                   dueTime:dueDate
                                                              timePrecised:timePrecised
                                                               description:description
                                                               andProgress:0];

    BSELF(self)
    HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        NSDate *date;
        if (response[@"duetime"] != [NSNull null]) {
            date = [[CloudDateConverter sharedMager] dateAndTimeFromString:[NSString stringWithFormat:@"%@ %@", response[@"deadline"], response[@"duetime"]]];
        } else {
            date = [[CloudDateConverter sharedMager] dateFromString:response[@"deadline"]];
        }
        bself.assignment = [[AgendaAssignment alloc] initWithTitle:response[@"title"]
                                                            withId:[response[@"id"] integerValue]
                                                           dueTime:date
                                                      timePrecised:response[@"duetime"] != [NSNull null]
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
        [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"AGENDA_TEACHER_ERROR")
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };

    [[NetworkManager  manager] postAssignmentWithAssignment:assignment
                                           withDisciplineID:self.disciplineID
                                                withClassID:self.classID
                                                  onSuccess:success
                                                  onFailure:failure];
    [DejalBezelActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"LOADING")].showNetworkActivityIndicator = YES;
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
    NSDate *dueDate = row.value;

    row = [self.form formRowWithTag:timePrecisedTag];
    bool timePrecised = [row.value boolValue];

    row = [self.form formRowWithTag:descriptionTag];
    NSString *description = row.value;

    AgendaAssignment *assignment = [[AgendaAssignment alloc] initWithOther:self.assignment];
    assignment.title = title;
    assignment.timePrecised = timePrecised;
    assignment.dueDate = dueDate;
    assignment.assignmentDescription = description;

    BSELF(self)
    HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        NSDate *date;
        if (response[@"duetime"] != [NSNull null]) {
            date = [[CloudDateConverter sharedMager] dateAndTimeFromString:[NSString stringWithFormat:@"%@ %@", response[@"deadline"], response[@"duetime"]]];
        } else {
            date = [[CloudDateConverter sharedMager] dateFromString:response[@"deadline"]];
        }
        bself.assignment = [[AgendaAssignment alloc] initWithTitle:response[@"title"]
                                                            withId:[response[@"id"] integerValue]
                                                           dueTime:date
                                                      timePrecised:response[@"duetime"] != [NSNull null]
                                                       description:response[@"wording"]
                                                  withCreationDate:[[CloudDateConverter sharedMager] dateAndTimeFromString:response[@"created_at"]]
                                                     andLastUpdate:[[CloudDateConverter sharedMager] dateAndTimeFromString:response[@"updated_at"]]
                                                     forDissipline:response[@"discipline"]
                                                           inClass:response[@"school_class"]];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
        [bself dismissViewControllerAnimated:YES completion:^{
            [bself.superPresenter.assignments addObject:bself.assignment];
            [bself.superPresenter.tableView reloadData];
        }];
    };

    HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"AGENDA_TEACHER_ERROR")
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };

    [[NetworkManager manager] patchAssignmentWithAssignment:assignment
                                           withDisciplineID:self.disciplineID
                                                withClassID:self.classID
                                                  onSuccess:success
                                                  onFailure:failure];
    [DejalBezelActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"LOADING")].showNetworkActivityIndicator = YES;
}

@end
