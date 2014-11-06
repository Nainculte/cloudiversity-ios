//
//  AgendaFilterDelegate.h
//  Cloudiversity
//
//  Created by Nainculte on 17/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#ifndef Cloudiversity_AgendaFilterDelegate_h
#define Cloudiversity_AgendaFilterDelegate_h

@protocol AgendaFilterDelegate

- (void)filtersUpdated:(NSDictionary *)newFilters;

@end

#endif
