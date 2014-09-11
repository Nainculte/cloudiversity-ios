//
//  AgendaTeacherEditAssignmentViewController.h
//  Cloudiversity
//
//  Created by Nainculte on 22/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UINavigationController.h>
#import "XLForm.h"
#import "UIColor+Cloud.h"
#import "AgendaAssignment.h"

@interface AgendaTeacherEditAssignmentViewController : UINavigationController

- (id)initWithDisciplineID:(int)disciplineID withClassID:(int)classID andAssignment:(AgendaAssignment *)assignment;

@property (nonatomic, assign) AgendaAssignment *assignment;

@property (nonatomic) int disciplineID;
@property (nonatomic) int classID;

@end

@interface AgendaTeacherEditFormViewController : XLFormViewController

@property (nonatomic, retain) AgendaAssignment *assignment;

@property (nonatomic) int disciplineID;
@property (nonatomic) int classID;

#define BSELF(ptr) __weak typeof(ptr) bself = ptr;

@end