//
//  HEViewController.h
//  Idol
//
//  Created by Sean Hess on 3/4/11.
//  Copyright 2011 I.TV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HEViewController : UIViewController {
    BOOL allowLandscape;
    BOOL allowPortrait;
}

@property (nonatomic) BOOL allowLandscape;
@property (nonatomic) BOOL allowPortrait;

@end
