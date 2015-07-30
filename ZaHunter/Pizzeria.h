//
//  Pizzeria.h
//  GoToJail
//
//  Created by Benjamin COOPER on 7/29/15.
//  Copyright (c) 2015 Ben Cooper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Pizzeria : NSObject

@property double distance;
@property NSString *name;
@property CLLocation *location;
@property MKMapItem *mapItem;

@end
