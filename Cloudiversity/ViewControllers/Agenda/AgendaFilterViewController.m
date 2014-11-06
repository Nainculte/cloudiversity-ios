//
//  AgendaFilterViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 08/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaFilterViewController.h"
#import "CloudDateConverter.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"AgendaStudentVC"]

#pragma mark - AgendaFilterRootViewController
@interface AgendaFilterRootViewController()

@end

@implementation AgendaFilterRootViewController

- (instancetype)init {
    AgendaFilterViewController *vc = [[AgendaFilterViewController alloc] init];
    self = [self initWithRootViewController:vc];
    self.filterVC = vc;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.navigationBar setBarTintColor:[UIColor cloudLightBlue]];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor cloudGrey];
}

@end

#pragma mark - AgendaFilterViewController
@interface AgendaFilterViewController()

@property (nonatomic, strong)XLFormRowDescriptor *isFilteringDateRow;
@property (nonatomic, strong)XLFormRowDescriptor *dateFilterRow;
@property (nonatomic, strong)XLFormRowDescriptor *progressFilteringRow;
@property (nonatomic, strong)XLFormSectionDescriptor *disciplineFilterSection;
@property (nonatomic, retain)NSMutableDictionary *disciplinesRows;

@property (nonatomic, retain)NSArray *progresses;
@property (nonatomic, retain)NSMutableDictionary *filters;
@property (nonatomic, retain)NSMutableArray *disciplinesSelected;

@end

@implementation AgendaFilterViewController

#pragma mark - Constants
static NSString *const isFilteringDateTag = @"isFilteringDate";
static NSString *const dateFilterTag = @"dateFilter";
static NSString *const progressFilteringTag = @"progressFiltering";
static NSString *const disciplineFilterTag = @"disciplineFilter";

#pragma mark - Initializers
- (instancetype)init {
    self = [super init];
    if (self) {
        XLFormDescriptor * form;
        XLFormSectionDescriptor * section;

        form = [XLFormDescriptor formDescriptorWithTitle:LOCALIZEDSTRING(@"FILTERS_TITLE")];

        // dateFilter
        section = [XLFormSectionDescriptor formSection];
        [form addFormSection:section];
        self.isFilteringDateRow = [XLFormRowDescriptor formRowDescriptorWithTag:isFilteringDateTag rowType:XLFormRowDescriptorTypeBooleanCheck title:LOCALIZEDSTRING(@"FILTERS_DATE")];
        [section addFormRow:self.isFilteringDateRow];
        self.dateFilterRow = [XLFormRowDescriptor formRowDescriptorWithTag:dateFilterTag rowType:XLFormRowDescriptorTypeDateInline title:@""];
        self.dateFilterRow.value = [NSDate new];

        section = [XLFormSectionDescriptor formSectionWithTitle:LOCALIZEDSTRING(@"FILTERS_PROGRESS")];
        [form addFormSection:section];
        self.progressFilteringRow = [XLFormRowDescriptor formRowDescriptorWithTag:progressFilteringTag rowType:XLFormRowDescriptorTypeSelectorSegmentedControl];
        self.progressFilteringRow.selectorOptions = self.progresses;
        self.progressFilteringRow.value = (self.progresses)[0];
        [section addFormRow:self.progressFilteringRow];

        self.disciplineFilterSection = [XLFormSectionDescriptor formSectionWithTitle:LOCALIZEDSTRING(@"FILTERS_DISCIPLINE")];
        [form addFormSection:self.disciplineFilterSection];
        self.form = form;
    }
    return self;
}

#pragma mark - View life cycle
- (void)viewWillAppear:(BOOL)animated {
    NSArray *disciplines = [self.dataSource getAvailableDisciplinesToFilter];
    self.disciplinesRows = [NSMutableDictionary dictionaryWithCapacity:disciplines.count];
    NSUInteger count = self.disciplineFilterSection.formRows.count;
    for (NSInteger i = 0; i < count; ++i) {
        [self.disciplineFilterSection removeFormRowAtIndex:0];
    }
    __block XLFormRowDescriptor *row;
    [disciplines enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        NSString *tag = [NSString stringWithFormat:@"%@", @(100 + idx)];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeBooleanCheck title:name];
        [self.disciplineFilterSection addFormRow:row];
        (self.disciplinesRows)[name] = row;
    }];
    self.filters = [[self.dataSource getFilters] mutableCopy];
    self.disciplinesSelected = [NSMutableArray arrayWithArray:(self.filters)[DISCIPLINE_FILTER_KEY]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tableView.frame = CGRectMake(52, self.tableView.frame.origin.y, self.tableView.frame.size.width - 52, self.tableView.frame.size.height);
}

#pragma mark - Form methods
- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    if ([formRow.tag isEqual:isFilteringDateTag]) {
        if ([formRow.value boolValue]) {
            [formRow.sectionDescriptor addFormRow:self.dateFilterRow afterRow:formRow];
            NSDate *date = self.dateFilterRow.value;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            (self.filters)[DATE_FILTER_KEY] = [[CloudDateConverter sharedMager] dateFromString:[formatter stringFromDate:date]];
        } else {
            [self.dateFilterRow.sectionDescriptor removeFormRow:self.dateFilterRow];
            [self.filters removeObjectForKey:DATE_FILTER_KEY];
        }
    } else if ([formRow.tag isEqual:dateFilterTag]) {
        NSDate *date = formRow.value;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        (self.filters)[DATE_FILTER_KEY] = [[CloudDateConverter sharedMager] dateFromString:[formatter stringFromDate:date]];
    } else if ([formRow.sectionDescriptor isEqual:self.disciplineFilterSection]) {
        NSSet *names = [self.disciplinesRows keysOfEntriesPassingTest:^BOOL(NSString *key, XLFormRowDescriptor *obj, BOOL *stop){
            if ([obj isEqual:formRow]) {
                return YES;
            }
            return NO;
        }];
        NSString *name = [names anyObject];
        if ([formRow.value boolValue]) {
            [self.disciplinesSelected addObject:name];
        } else {
            [self.disciplinesSelected removeObject:name];
        }
        if (self.disciplinesSelected.count) {
            (self.filters)[DISCIPLINE_FILTER_KEY] = self.disciplinesSelected;
        } else {
            [self.filters removeObjectForKey:DISCIPLINE_FILTER_KEY];
        }
    } else if ([formRow.tag isEqual:progressFilteringTag]) {
        NSInteger index = [self.progresses indexOfObject:formRow.value];
        (self.filters)[PROGRESS_FILTER_KEY] = @(index);
    }
    [self.delegate filtersUpdated:self.filters];
}

#pragma mark - Properties
-(NSArray *)progresses {
    if (!_progresses) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
        [array addObject:LOCALIZEDSTRING(@"FILTERS_TODO")];
        [array addObject:LOCALIZEDSTRING(@"FILTERS_ALL")];
        [array addObject:LOCALIZEDSTRING(@"FILTERS_DONE")];
        _progresses = array;
    }
    return _progresses;
}

@end
