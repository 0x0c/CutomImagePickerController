//
//  CIPImagePickerController.h
//  CustomImagePickerTest
//
//  Created by 暁 松田 on 11/11/19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CIPImagePickerController : UIImagePickerController
{
	CALayer *activeFrame;
	AVCaptureDevice *device;
	UIDeviceOrientation orientation;
	
	BOOL focus;
	BOOL tap;
}

- (void)focusAtPoint:(CGPoint)point;
- (void)focus;
- (void)didRotate:(NSNotification *)notification;

@end
