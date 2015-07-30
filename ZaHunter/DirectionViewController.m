//
//  DirectionViewController.m
//  ZaHunter
//
//  Created by Benjamin COOPER on 7/29/15.
//  Copyright (c) 2015 Ben Cooper. All rights reserved.
//

#import "DirectionViewController.h"

@interface DirectionViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DirectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpAnnotations];

    [self.mapView setShowsUserLocation:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
 //   [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    [self getDirections:self.customAnnotation.pizzeria.mapItem];

}

-(void)setUpAnnotations
{
    NSMutableArray *annotationArray = [NSMutableArray new];

    [self.mapView addAnnotation:self.customAnnotation];
    [annotationArray addObject:self.customAnnotation];

    [self.mapView showAnnotations:annotationArray animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];

    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else
    {
        view.image = [UIImage imageNamed:@"za"];
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoDark];
    }

    return view;
}

-(void)getDirections:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destination;
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
    {
        NSArray *routes = response.routes;
        MKRoute *route = routes.firstObject;
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }];
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        return routeRenderer;
    }
    else
    {
        return nil;
    }
}



@end
