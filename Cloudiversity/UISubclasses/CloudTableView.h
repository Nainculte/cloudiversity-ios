//
//  CloudTableView.h
//  Cloudiversity
//
//  Created by Nainculte on 13/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudTableViewDelegate.h"

@interface CloudTableView : UITableView {
    struct {
        unsigned int delegateWillReloadData:1;
        unsigned int delegateDidReloadData:1;
        unsigned int reloading:1;
    } _flags;
}
@end
