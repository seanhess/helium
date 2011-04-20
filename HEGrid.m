//
//  HEGrid.m
//  Idol
//
//  Created by Sean Hess on 3/3/11.
//  Copyright 2011 I.TV. All rights reserved.
//

#import "HEGrid.h"
#import "Helium.h"

@implementation HEGrid

@synthesize columnsInPortrait, columnsInLandscape;
@synthesize cellNibName, items, rowHeight, cellCb;

- (void)dealloc {
    [cellCb release];
    [items release];
    [cellNibName release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

















-(NSInteger)columns {
    return 6;
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) 
        return columnsInLandscape;
    
    else
        return columnsInPortrait;
}

- (void)setItems:(NSArray *)newItems {
    if (items != newItems) {
        [items release];        
        items = [newItems retain];
        [self reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int columns = [self columns];
    if (columns == 0) return 0;
    return (items.count / columns); // what I really need is to round up
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString*)reuseIdentifier {
    return (self.cellNibName) ? self.cellNibName : @"UITableViewCell";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rowHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier];
    
    if (cell == nil) {
        
        if (self.cellNibName) {
            NSArray* nib = [[NSBundle mainBundle] loadNibNamed:self.cellNibName owner:nil options:nil];
            cell = [nib objectAtIndex:0];             
        }
        
        else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.reuseIdentifier] autorelease];
        }
    }
    
    
    // Wait, this isn't even going to work, because we'd need a different nib in landscape and portrait, right? 
    // Still, I like that I don't have to lay it out. 
    
    int row = indexPath.row;
    int columns = self.columns;
    int leftOffset = row * columns;
    
    for (int i = 0; i < columns; i++) {
        
        int mainIndex = leftOffset + i;
        NSArray * subviews = [cell.contentView subviews];
        
        if (subviews.count > 0) {
            UIView * childCell = [subviews objectAtIndex:i];
            
            // Get the delegate to set the data
            [[Helium shared] call:cellCb object:[NSNumber numberWithInt:mainIndex] object:childCell];                    
        }
        
    }
    
    return cell;
}


@end
