//
//  CIPViewController.m
//  CustomImagePickerTest
//
//  Created by 暁 松田 on 11/11/19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CIPViewController.h"
#import "CIPImagePickerController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CIPViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)showPicker:(id)sender
{
	if ([CIPImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		CIPImagePickerController *imagePickerController = [[CIPImagePickerController alloc] init];
		
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		imagePickerController.delegate = self;
        imagePickerController.showsCameraControls = NO;
		
		//custom tool bar
		UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, imagePickerController.view.frame.size.height - 54, 320, 54)];
		CALayer* subLayer = [CALayer layer];
		subLayer.frame = CGRectMake(0, 0, 320, 54);
		UIGraphicsBeginImageContext(CGSizeMake(50, 54));
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGColorSpaceRef colorspace;
		CGGradientRef gradient;
		CGFloat locations[2]  = { 0.0, 1.0 };
		CGFloat components[8] = {
			1.0, 1.0, 1.0, 1.0,
			0.4, 0.4, 0.45, 1.0
		};
		colorspace = CGColorSpaceCreateDeviceRGB();
		gradient   = CGGradientCreateWithColorComponents (colorspace, components, locations, 2);
		CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, 54), 0);
		UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		subLayer.contents = (id)img.CGImage;
		[toolbar.layer addSublayer:subLayer];
		toolbar.layer.zPosition = 2000;
		toolbar.layer.shadowOpacity = 0.5;
		toolbar.layer.shadowOffset = CGSizeMake(-2, -1);
		[imagePickerController.cameraOverlayView addSubview:toolbar];
		
		[self presentModalViewController:imagePickerController animated:YES];
		[imagePickerController release];
    }
	else {
		NSLog(@"no camera");
	}
}

@end
