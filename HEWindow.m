//
//  HEWindow.m
//  Idol
//
//  Created by Sean Hess on 3/4/11.
//  Copyright 2011 I.TV. All rights reserved.
//

#import "HEWindow.h"
#import "Helium.h"

@implementation HEWindow

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event 
{
    if (event.type == UIEventSubtypeMotionShake) 
    {
        [[Helium shared] refresh];   
    }
}

@end
