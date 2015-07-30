//
//  CustomAnnotationStuff.h
//  ZaHunter
//
//  Created by Benjamin COOPER on 7/29/15.
//  Copyright (c) 2015 Ben Cooper. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Pizzeria.h"

@interface CustomAnnotationStuff : MKPointAnnotation

@property Pizzeria *pizzeria;

@end
