//
//  HEProxyWebView.h

#import <UIKit/UIKit.h>

@interface HEProxyWebView : UIWebView {
    NSMutableDictionary * scripts;
}

@property (nonatomic, readonly) NSMutableDictionary * scripts;

@end
