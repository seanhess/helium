//
//  HERoot.m
//  Idol
//
//  Created by Sean Hess on 3/2/11.
//  Copyright 2011 I.TV. All rights reserved.
//

#import "Helium.h"
#import "JSONKit.h"
#import "HEProxyWebView.h"


#import <UIKit/UIKit.h>


@interface Helium ()
- (void)loadRootUrl;
- (void)parseHeliumCommand:(NSURL*)url;
- (void)loadPage:(UIViewController*)viewController;
- (NSString*)argument:(id)object;
- (id)translate:(id)object;
@end

@implementation Helium

@synthesize proxy, callbacks, view, objects, pageViewController;

- (void)dealloc
{
    [pageViewController release];
    [objects release];
    [view release];
    [callbacks release];
    [proxy release];
    [super dealloc];
}

+ (Helium*)shared {
    static Helium * instance = nil;
    
    if (!instance) {
        instance = [Helium new];
    }
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {       
        // see loadRootURL
    }
    return self;
}










- (NSNumber*)expose:(id)object {
    
    if (!object) return nil;
    
    NSNumber * objectId = [NSNumber numberWithInt:++currentId];

//    [self.objects setObject:object forKey:objectId];
    
    NSValue * value = [NSValue valueWithNonretainedObject:object];
    [self.objects setObject:value forKey:objectId];
    
    return objectId;
}

- (id)restore:(NSString*)objectId {

//    id object = [self.objects objectForKey:objectId];    
    
    NSValue * value = [self.objects objectForKey:objectId];
    id object = [value nonretainedObjectValue];
    
    return object;
}












- (UIView*)find:(UIView*)startView class:(Class)class tag:(NSInteger)tag {
    
    // TODO: Optimize (one level at a time? Only do bundle items?)
    
    for (UIView * subView in [startView subviews]) {
        if ([subView class] == class) {
            if (tag == 0 || tag == [subView tag]) {
                return subView;
            }            
        }
        
        UIView * result = [self find:subView class:class tag:tag];
        if (result) 
            return result;        
    }
    
    return nil;
}


- (UIView*)find:(id)start selector:(NSString*)selector {
    
    NSArray * components = [selector componentsSeparatedByString:@"."];
    NSString * type = [components objectAtIndex:0];
    Class class = NSClassFromString(type);
    NSInteger tag = (components.count > 1) ? [[components objectAtIndex:1] intValue] : 0;    
    
    if ([start isKindOfClass:[UIViewController class]]) {
        start = [start view];
    }
    
    if (![start isKindOfClass:[UIView class]]) {
        NSLog(@"ERROR: Find called on non-view %@", start);
        return nil;
    }
    
    return [self find:start class:class tag:tag];
}








- (void)refresh {
    [self loadRootUrl];
}

- (void)loadRootUrl {
    
    // I need to bootstrap it with jQuery before I do anything else
    // Because it won't tell me if it fails. Lame. 
    // Well, I can have the app ping it independently and give you an error
    
    self.callbacks = [NSMutableDictionary dictionary];
    self.objects = [NSMutableDictionary dictionary];
    currentId = 0;
    
    self.proxy = [[[HEProxyWebView alloc] initWithFrame:CGRectZero] autorelease];
    self.proxy.delegate = self;
    
    NSString * html = [NSString stringWithFormat:@"<html><head><script data-main='scripts/idol' src='scripts/require-jquery.js'></script></head><body><h1>Debug3</h1></body></html>"];
    [self.proxy loadHTMLString:html baseURL:[NSURL URLWithString:@"http://localhost:4567/"]];
}

- (void)loadPage:(UIViewController*)viewController {    
    [self.pageViewController.view removeFromSuperview];
    self.pageViewController = viewController;
    [view addSubview:viewController.view];            
}

+ (id)loadNib:(NSString*)name; {
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];
    return [nib objectAtIndex:0]; 
}










- (void)bridge:(NSString*)method requestId:(NSString*)requestId obj:(id)obj1 obj:(id)obj2 {
    
    NSMutableString * command = [NSMutableString stringWithString:@"window.bridge."];
    [command appendString:method];
    
    // requestId
    [command appendFormat:@"(%@", requestId];    
    
    // arguments
    if (obj1) [command appendFormat:@", %@", obj1];     
    if (obj2) [command appendFormat:@", %@", obj2];     
    
    [command appendString:@")"];
    
    dispatch_async(dispatch_get_main_queue(), ^{    
        [self.proxy stringByEvaluatingJavaScriptFromString:command]; 
    });
}



- (void)callback:(NSString*)requestId object:(id)obj1 object:(id)obj2 {
    
    // Should automatically send nil if object is nil

    [self bridge:@"callback" 
       requestId:requestId 
             obj:[self argument:obj1]
             obj:[self argument:obj2]];    
    
}

- (void)call:(NSString*)requestId object:(id)obj1 object:(id)obj2 {
    
    // If obj1 is something OTHER than 

    [self bridge:@"call" 
       requestId:requestId 
             obj:[self argument:obj1] 
             obj:[self argument:obj2]];
    
}

- (NSString*)argument:(id)object {
    
    if (!object) return nil;
    if ([object isKindOfClass:[NSString class]]) return object;
    if ([object isKindOfClass:[NSNumber class]]) return object;
    
    NSNumber * objectId = [self expose:object];
    return [NSString stringWithFormat:@"{proxy:%@}", objectId];
}


















- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL * url = [request URL];
    
    if ([[url scheme] isEqualToString:@"helium"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            [self parseHeliumCommand:url];
        });
        return NO;
    }
    
    return YES;        
}

- (void)parseHeliumCommand:(NSURL*)url {

    // PARSE MAIN
    
    NSString * urlString = [url absoluteString];    
    
    NSRange lastSlashRange = [urlString rangeOfString:@"/" options:NSBackwardsSearch];
    NSString * json = [[urlString substringFromIndex:lastSlashRange.location+1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    json = [json stringByReplacingOccurrencesOfString:@"||" withString:@"/"];
    
    NSLog(@"UMMM %@", json);
    
    NSArray * queue = [json objectFromJSONString];
    
    
    for (NSDictionary * data in queue) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{

            // PARSED PROPERTIES
            NSString * requestId = [data objectForKey:@"requestId"];
            NSString * action = [data objectForKey:@"action"];
            NSString * context = [data objectForKey:@"context"];
            id object = [self restore:context];  
            // void(^callback)(id obj) = [self.callbacks objectForKey:method];
            
            
            NSLog(@"HELIUM: %@", data);    
            
            if ([action isEqualToString:@"load"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadPage:[Helium loadNib:[data objectForKey:@"nibName"]]];                                                                
                    [self callback:requestId object:self.pageViewController object:nil];                         
                });
            }
            
            else if ([action isEqualToString:@"find"]) {
                UIView * found = [self find:object selector:[data objectForKey:@"selector"]];        
                [self callback:requestId object:found object:nil];
            }
            
            else if ([action isEqualToString:@"set"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // only supports strings/numbers/arrays of dictionaries  
                    id value = [self translate:[data objectForKey:@"value"]];
                    [object setValue:value forKeyPath:[data objectForKey:@"keyPath"]];
                });
            }
            
            else if ([action isEqualToString:@"handle"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [object setValue:requestId forKeyPath:[data objectForKey:@"keyPath"]];
                });
            }
            
            else if ([action isEqualToString:@"call"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [object performSelector:NSSelectorFromString([data objectForKey:@"selector"])];
                });
            }
            
            //    if ([method isEqualToString:@"display"]) {
            //        
            //        dispatch_async(dispatch_get_main_queue(), ^{            
            //            UIViewController * nav = [[self translate:data] retain];
            //            [self.view addSubview:nav.view];                
            //        });
            //    }
            //    
            //    else if ([method isEqualToString:@"call"]) {
            //        /*
            //         {
            //             id: id, 
            //             keyPath: keyPath, 
            //             selector: selector, 
            //             arguments: Array.prototype.slice.call(arguments, 1)
            //         }
            //         */
            //        
            //        NSString * objectId = [data objectForKey:@"id"];
            //        NSString * keyPath = [data objectForKey:@"keyPath"];
            //        
            //        id obj = [objects objectForKey:objectId];
            //        
            //        if (keyPath) {
            //            obj = [obj valueForKeyPath:keyPath];
            //        }
            //        
            //        dispatch_async(dispatch_get_main_queue(), ^{
            //            [self forwardCallToObject:obj dictionary:data];            
            //        });
            //    }
            //    
            //    else if ([method isEqualToString:@"hereyougo"]) {
            //        dispatch_async(dispatch_get_main_queue(), ^{
            //            HEJSObject * object = [HEJSObject objectWithDictionary:data];
            //            [object call:@"test()"];
            //        });
            //    }    
            //    
            //    else if (callback) {
            //        callback(data);
            //        [self.callbacks removeObjectForKey:method];
            //    }

        });
    }    
}



- (id)translate:(id)object {
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary * dict = (NSDictionary*)object;
        NSString * type = [dict objectForKey:@"_type"];
        Class class = NSClassFromString(type);
        
        if (class == [UIImage class]) {
            NSURL *url = [NSURL URLWithString:[dict objectForKey:@"url"]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];
            
            return img;
        }
        
        
    }
    
    return object;
}

//- (id)translate:(id)data {
//    
//    
//    if ([data isKindOfClass:[NSDictionary class]]) {
//        
//        // Create the object based on the passed-in type
//        // This actually CREATES it (should add a lookup later)
//        
//        NSString * type = [data objectForKey:@"type"];   
//        NSDictionary * init = [data objectForKey:@"init"];
//        
//        Class class = NSClassFromString(type);
//        
//        id obj = [class alloc];
//        
//        
//        // INITIALIZE // 
//        NSLog(@"HELIUM: create %@", NSStringFromClass(class));                        
//        
//        if (init) {
//            obj = [self forwardCallToObject:obj dictionary:init];
//        }
//        
//        else {
//            obj = [obj init];        
//        }
//        
//        [obj autorelease];
//        
//        
//        
//        
//    
//        
//        
//        
//        // COPY PROPERTIES // 
//        
//        NSDictionary * values = [data objectForKey:@"values"];
//        if (values) {
//            [obj setValuesFromJS:values];
//        }
//        
//        
//        
//        
//        
//        
//        
//        // PROXY OBJECTS // 
//        
//        if ([data objectForKey:@"proxy"]) {
//            // save it for laterz
//            [objects setObject:obj forKey:[data objectForKey:@"_id"]];
//        }
//        
//        
//        
//       
//
//        
//        return obj;
//    }
//    
//    else {
//        return data;
//    }
//    
//}
//
//
//- (id)forwardCallToObject:(id)object dictionary:(NSDictionary*)dict {
//    SEL initSelector = NSSelectorFromString([dict objectForKey:@"selector"]);
//    NSArray * arguments = [dict objectForKey:@"arguments"];
//    NSInteger count = [arguments count];
//    id argument1 = nil;
//    id argument2 = nil;
//    
//    if (count > 0) {
//        argument1 = [arguments objectAtIndex:0];                
//        if (argument1) argument1 = [self translate:argument1];                
//    }
//    
//    if (count > 1) {
//        argument2 = [arguments objectAtIndex:1];
//        if (argument2) argument2 = [self translate:argument2];                            
//    }
//    
//    NSLog(@"HELIUM: calling selector=%@ arg1=%@ arg2=%@", NSStringFromSelector(initSelector), argument1, argument2);    
//    return [object performSelector:initSelector withObject:argument1 withObject:argument2]; 
//}
//
//
//
//
//
//
//
//
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    NSLog(@"Helium Start Load");
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSLog(@"Helium Finish Load");
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"HELIUM FAIL LOAD %@", error);
//}


//- (void)call:(NSString*)method callback:(void(^)(NSDictionary*))block {
//    
//    static NSInteger callId = 1;
//    
//    NSString * localCallId = [NSString stringWithFormat:@"%i", callId++];
//    
//    // save the callback with the id of the call. 
//    void(^callback)(NSDictionary*) = [[block copy] autorelease];
//    [self.callbacks setObject:callback forKey:localCallId];
//    
//    NSMutableString * command = [NSMutableString string];
//    [command appendFormat:@"%@(", method];
//    
//    // Add Arguments Here
//    
//    [command appendFormat:@"allHeliumWoot.generateReply(%@))", localCallId];
//    
//    [self.proxy stringByEvaluatingJavaScriptFromString:command]; // OR, just return something. No, cb-based
//}











@end
