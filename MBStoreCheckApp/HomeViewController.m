//
//  HomeViewController.m
//  MBStoreCheckApp
//
//  Created by Michael Babiy on 6/2/14.
//  Copyright (c) 2014 Michael Babiy. All rights reserved.
//

#import "HomeViewController.h"
#import "MBStoreCheck.h"

@interface HomeViewController () <UIAlertViewDelegate>

- (IBAction)paidFeatureButtonSelected:(UIButton *)sender;
- (IBAction)resetUserDefaultsButtonSelected:(UIButton *)sender;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)paidFeatureButtonSelected:(UIButton *)sender
{
    if ([[MBStoreCheck sharedStoreCheck]isAuthorized]) {
        NSLog(@"User bought the item already...");
    } else {
        [[[UIAlertView alloc]initWithTitle:@"Feature Locked"
                                   message:@"Would you like to upgrade to the Pro version?"
                                  delegate:self
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:@"Yes", nil]show];
    }
}

- (IBAction)resetUserDefaultsButtonSelected:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kUserAuthorized];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [[MBStoreCheck sharedStoreCheck]authorize];
            break;
            
        default:
            break;
    }
}

@end
