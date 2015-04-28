//
//  myImv.m
//  3DM
//
//  Created by Frcc on 15-4-28.
//  Copyright (c) 2015年 3DM. All rights reserved.
//

#import "myImv.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"

@implementation myImv

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)pan:(UIGestureRecognizer*)gr{
    if (gr.state == UIGestureRecognizerStateEnded) {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = self.image;
        imageInfo.referenceRect = self.frame;
        imageInfo.referenceView = self.superview;
        imageInfo.referenceContentMode = self.contentMode;
        imageInfo.referenceCornerRadius = self.layer.cornerRadius;
        
        // Setup view controller
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        
        // Present the view controller.
        [imageViewer showFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
}

@end
