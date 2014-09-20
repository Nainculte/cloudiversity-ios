//
//  AgendaTeacherTableViewCell.h
//  Cloudiversity
//
//  Created by Nainculte on 14/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICloud.h"

@interface AgendaTeacherTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CloudLabel *classLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *assignmentsLabel;
@end
