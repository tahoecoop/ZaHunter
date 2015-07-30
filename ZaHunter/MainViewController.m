//
//  ViewController.m
//  ZaHunter
//
//  Created by Benjamin COOPER on 7/29/15.
//  Copyright (c) 2015 Ben Cooper. All rights reserved.
//

#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Pizzeria.h"
#import "DirectionViewController.h"
#import "CustomAnnotationStuff.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property CLLocationManager *locationManager;
@property NSMutableArray *pizzasArray;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property NSArray *sortedPizzeria;
@property double totalTravelTime;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property NSMutableArray *quatroArray;
@property int arrayCounter;
@property (weak, nonatomic) IBOutlet UISegmentedControl *walkDriveSegControl;


@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pizzasArray = [NSMutableArray new];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100;
    [self.locationManager startUpdatingLocation];
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    self.arrayCounter = 3;
 


}

#pragma mark - Tableview Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.quatroArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Pizzeria *pizzeria = [self.quatroArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZaCell"];
    NSLog(@"%f",pizzeria.distance);
    if (pizzeria.distance <= 15)
    {
        cell.textLabel.text = pizzeria.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f miles away", pizzeria.distance];


    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *someCrazyThing = [NSString stringWithFormat:@"Total travel/eating time: %.2f", self.totalTravelTime];

    return someCrazyThing;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.arrayCounter++;
    [tableView beginUpdates];
    [self.quatroArray removeObjectAtIndex:indexPath.row];
    [self.pizzasArray removeObject:[self.sortedPizzeria objectAtIndex:indexPath.row]];
//    [self.sortedPizzeria removeObjectAtIndex:indexPath.row];

    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    Pizzeria *pizzeria = [self.sortedPizzeria objectAtIndex:self.arrayCounter];
//    [self sortPizzeria];
    if (pizzeria.distance < 15)
    {
        [self.quatroArray addObject:[self.sortedPizzeria objectAtIndex:self.arrayCounter]];
        NSIndexPath *indexPathBottom = [NSIndexPath indexPathForRow:3 inSection:0];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathBottom, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    [tableView endUpdates];
//    [self.tableView reloadData];

}



#pragma mark - Location Methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.firstObject;
        if (location.verticalAccuracy < 100 && location.horizontalAccuracy < 100)
        {
            [self findPizzaNow:location];
            [self.locationManager stopUpdatingLocation];

        }
}

- (void)findPizzaNow:(CLLocation *)location
{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizzeria";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.5, .5));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        NSArray *mapItems = response.mapItems;

        for (MKMapItem *mapItem in mapItems)
        {
            Pizzeria *pizzeria = [Pizzeria new];
            pizzeria.name = mapItem.name;
            pizzeria.location = mapItem.placemark.location;

            CLLocationDistance distance = [pizzeria.location distanceFromLocation:self.locationManager.location];
            pizzeria.distance = distance / 1609.34;

            pizzeria.mapItem = mapItem;

            [self.pizzasArray addObject:pizzeria];
        }
        [self sortPizzeria];
        [self travelTime];
    }];
 }

-(void)sortPizzeria
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
   self.sortedPizzeria = [self.pizzasArray sortedArrayUsingDescriptors:sortDescriptors];

//    self.sortedPizzeria = [NSMutableArray arrayWithArray:array];
    self.quatroArray = [NSMutableArray new];
    for (int i = 0; i < 4; i++)
    {
        [self.quatroArray addObject:self.sortedPizzeria[i]];

    }
//    [self.tableView reloadData];

}

-(void)travelTime
{
    MKMapItem *origin;
    MKMapItem *destination;
    self.totalTravelTime = 200;
    for (int i = 0; i < 4; i++)
    {
        Pizzeria *pizzeriaOrigin;
        Pizzeria *pizzeriaDestination = [self.sortedPizzeria objectAtIndex:i];
        destination = pizzeriaDestination.mapItem;
        if (i == 0)
        {
            origin = [MKMapItem mapItemForCurrentLocation];
        }
        else
        {
            pizzeriaOrigin = [self.sortedPizzeria objectAtIndex:i - 1];
            origin = pizzeriaOrigin.mapItem;
        }

        MKDirectionsRequest *request = [MKDirectionsRequest new];
        request.source = origin;
        request.destination = destination;
        if (self.walkDriveSegControl.selectedSegmentIndex == 0)
        {
            request.transportType = MKDirectionsTransportTypeWalking;
        }
        else
        {
            request.transportType = MKDirectionsTransportTypeAutomobile;
        }

        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
        {
            NSArray *routes = response.routes;
            MKRoute *route = routes.firstObject;
            self.totalTravelTime += (double)route.expectedTravelTime / 60;
            [self.tableView reloadData];
        }];
    }
}

- (IBAction)onSegControlToggle:(UISegmentedControl *)sender
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        self.mapView.hidden = YES;
    }
    else
    {
        self.mapView.hidden = NO;
        [self setUpAnnotations];
    }
}

#pragma mark - Map Methods

-(void)setUpAnnotations
{
    NSMutableArray *annotationArray = [NSMutableArray new];
    for (int i = 0; i < 4; i++)
    {
        Pizzeria *pizzeria = [self.sortedPizzeria objectAtIndex:i];
        CustomAnnotationStuff *point = [CustomAnnotationStuff new];
        point.title = pizzeria.name;
        point.coordinate = pizzeria.location.coordinate;
        point.pizzeria = pizzeria;

        [self.mapView addAnnotation:point];
        [annotationArray addObject:point];
    }
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

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"directionsSegue" sender:view];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MKAnnotationView *view = sender;
    DirectionViewController *vc = segue.destinationViewController;
    vc.customAnnotation = view.annotation;
}
- (IBAction)onWalkDriveToggle:(UISegmentedControl *)sender
{
    [self travelTime];
}

@end
