//
//  HEGrid.h
//  Idol
//
//  Created by Sean Hess on 3/3/11.
//  Copyright 2011 I.TV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HEGrid : UITableView <UITableViewDelegate, UITableViewDataSource> {
    NSInteger columnsInPortrait;
    NSInteger columnsInLandscape;
    CGFloat rowHeight;
    
    NSString * cellNibName;
    
    NSArray * items;
    
    
    NSString * cellCb;
}

@property (nonatomic, retain) NSArray * items;

@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, copy) NSString * cellNibName;
@property (nonatomic, assign) NSInteger columnsInPortrait;
@property (nonatomic, assign) NSInteger columnsInLandscape;

@property (nonatomic, copy) NSString * cellCb;

@end
