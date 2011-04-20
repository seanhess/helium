//
//  HEViewController.m
//  Idol
//
//  Created by Sean Hess on 3/4/11.
//  Copyright 2011 I.TV. All rights reserved.
//

#import "HEViewController.h"


@implementation HEViewController

@synthesize allowPortrait, allowLandscape;

- (void)dealloc {
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        allowPortrait = NO;
        allowLandscape = YES;
    }
    return self;
}





- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
//        return allowLandscape;
//    else
//        return allowPortrait;
    return YES;
}

@end
