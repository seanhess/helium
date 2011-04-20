//
//  HERoot.h
//  Idol
//
//  Created by Sean Hess on 3/2/11.
//  Copyright 2011 I.TV. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Helium : NSObject <UIWebViewDelegate> {
    UIWebView * proxy;
    NSMutableDictionary * callbacks;
    NSMutableDictionary * objects;
    
    NSInteger currentId;
    
    UIViewController * pageViewController;
    UIView * view;    
}

- (void)loadRootUrl;
- (void)refresh;

@property (nonatomic, retain) UIWebView * proxy;
@property (nonatomic, retain) NSMutableDictionary * callbacks;
@property (nonatomic, retain) NSMutableDictionary * objects;
@property (nonatomic, retain) UIViewController * pageViewController;

@property (nonatomic, retain) UIView * view;

+ (Helium*)shared;
+ (id)loadNib:(NSString*)name;




- (void)call:(NSString*)requestId object:(id)obj1 object:(id)obj2;

@end
