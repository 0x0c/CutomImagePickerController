//
//  CIPImagePickerController.m
//  CustomImagePickerTest
//
//  Created by 暁 松田 on 11/11/19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CIPImagePickerController.h"

@implementation CIPImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
	self = [super init];
	if (self) {
		activeFrame = nil;
		device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];

	}
	
	return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	[super loadView];
	if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
		[device addObserver:self
				 forKeyPath:@"adjustingFocus"
					options:(NSKeyValueObservingOptionOld)
					context:nil];
	}
	
	if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
		[device addObserver:self
				 forKeyPath:@"adjustingExposure"
					options:NSKeyValueObservingOptionNew
					context:nil];
	}
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
	if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
		[device removeObserver:self forKeyPath:@"adjustingFocus"];
	}
	
	if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
		[device removeObserver:self forKeyPath:@"adjustingExposure"];
	}
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	tap = YES;
	CGPoint point = [[touches anyObject] locationInView:self.cameraOverlayView];

	CALayer *focusFrame = [CALayer layer];
	[activeFrame removeFromSuperlayer];
	focusFrame.bounds = CGRectMake(0, 0, 70, 70);
	focusFrame.position = CGPointMake(point.x, point.y);
	
	CGFloat border_rgba[] = { 0.9, 0.9, 1.0, 1.0 };
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef borderColor = CGColorCreate(colorSpace, border_rgba);
	focusFrame.borderColor = borderColor;
	focusFrame.borderWidth = 1.5;
	focusFrame.shadowColor = [[UIColor blueColor] CGColor];
	focusFrame.shadowOffset = CGSizeMake(0, 0);
	focusFrame.shadowOpacity = 1.0;
	CGColorRelease(borderColor);
	CGColorSpaceRelease(colorSpace);
	
	CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
	flash.duration = 0.2;
    flash.repeatCount = 999;
	flash.autoreverses = YES;
    flash.fromValue = [NSNumber numberWithFloat:1.0];
    flash.toValue = [NSNumber numberWithFloat:0.0];
	[focusFrame addAnimation:flash forKey:@"opacity"];
	
	CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scale.duration = 0.2;
    scale.repeatCount = 1;
    scale.fromValue = [NSNumber numberWithFloat:1.5];
    scale.toValue = [NSNumber numberWithFloat:1.0];
	[focusFrame addAnimation:scale forKey:@"transform.scale"];
	
	[self.cameraOverlayView.layer addSublayer:focusFrame];
	activeFrame = focusFrame;
	
	point.x = 1.0 - point.y / self.cameraOverlayView.bounds.size.height;
	point.y = point.x / self.cameraOverlayView.bounds.size.width;
	
	[self focusAtPoint:point];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"adjustingFocus"]) {
		if ([change objectForKey:NSKeyValueChangeNewKey] == NO) {
			NSLog(@"f");
			if (!tap) {
				[self focus];
			}
			if (focus) {
				NSLog(@"focus");
				[activeFrame removeAllAnimations];
				[activeFrame removeFromSuperlayer];
				activeFrame = nil;
				focus = NO;
				tap = NO;
			}
			else {
				focus = YES;
			}
		}
	}
	
	if ([keyPath isEqual:@"adjustingExposure"]) {
		if ([change objectForKey:NSKeyValueChangeNewKey] == NO) {
			NSError *error = nil;
			if ([device lockForConfiguration:&error]) {
				[device setExposureMode:AVCaptureExposureModeLocked];
				[device unlockForConfiguration];
			}
		}
	}
}

- (void)focusAtPoint:(CGPoint)point
{
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
		if ([device lockForConfiguration:&error]) {
			device.focusMode = AVCaptureFocusModeAutoFocus;			
			[device setFocusPointOfInterest:point];
			
			[device unlockForConfiguration];
		}
	}
	
	if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setExposurePointOfInterest:point];
			device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
			
			[device unlockForConfiguration];
		}
	}
}

- (void)focus
{
	CALayer *focusFrame = [CALayer layer];
	[activeFrame removeFromSuperlayer];
	focusFrame.bounds = CGRectMake(0, 0, 150, 150);
	CGPoint point = self.cameraOverlayView.center;
	point.y -= 54 / 2;
	focusFrame.position = point;
	
	CGFloat border_rgba[] = { 0.9, 0.9, 1.0, 1.0 };
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef borderColor = CGColorCreate(colorSpace, border_rgba);
	focusFrame.borderColor = borderColor;
	focusFrame.borderWidth = 1.5;
	focusFrame.shadowColor = [[UIColor blueColor] CGColor];
	focusFrame.shadowOffset = CGSizeMake(0, 0);
	focusFrame.shadowOpacity = 1.0;
	CGColorRelease(borderColor);
	CGColorSpaceRelease(colorSpace);
	
	CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
	flash.duration = 0.2;
    flash.repeatCount = 999;
	flash.autoreverses = YES;
    flash.fromValue = [NSNumber numberWithFloat:1.0];
    flash.toValue = [NSNumber numberWithFloat:0.0];
	[focusFrame addAnimation:flash forKey:@"opacity"];
	
//	CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"scale"];
//	scale.duration = 0.2;
//    scale.repeatCount = 1;
//    scale.fromValue = [NSNumber numberWithFloat:2.0];
//    scale.toValue = [NSNumber numberWithFloat:1.0];
//	[focusFrame addAnimation:flash forKey:@"scale"];
	
	[self.cameraOverlayView.layer addSublayer:focusFrame];
	activeFrame = focusFrame;
}

- (void)didRotate:(NSNotification *)notification
{
	NSLog(@"rotate");
	orientation = [[notification object] orientation];
}

@end
