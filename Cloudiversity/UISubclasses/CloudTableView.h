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
        BOOL delegateWillReloadData:1;
        BOOL delegateDidReloadData:1;
        BOOL reloading:1;
    } _flags;
}
@end
