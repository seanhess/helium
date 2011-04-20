//
//  HEProxyWebView.m
//

//  See: https://github.com/rsanders/nitrox
//  Only uses private framework when debugging. 

#if DEBUG
@class WebView;
@class WebScriptObject;
@class WebScriptCallFrame;
#endif

#import "HEProxyWebView.h"

@implementation HEProxyWebView

- (void)dealloc {
    [scripts release];
    [super dealloc];
}

- (NSMutableDictionary*)scripts {
    if (!scripts) {
        scripts = [NSMutableDictionary new];
    }
    return scripts;
}








#if DEBUG
#pragma mark Undocumented / Private methods

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame
{
    NSLog(@"HeDebug Loaded %i", (webView != nil));    
//    [webView setScriptDebugDelegate:self];    
    [(NSObject*)webView performSelector:@selector(setScriptDebugDelegate:) withObject:self];
}

// never seems to get called
- (void)webView:(id)webView addMessageToConsole:(NSDictionary *)dictionary
{
    NSLog(@"adding message to console: %@", dictionary);
}

// never seems to get called
- (void) _reportError:(id)error
{
    NSLog(@"reporting error: %@", error);
}

#if TARGET_IPHONE_SIMULATOR
#  ifndef IPHONE_SDK_KOSHER

// TODO: the following two methods should be synchronous, and not return until
//   the user has interacted with the UI.

// Javascript alerts
- (void) webView: (WebView*)webView runJavaScriptAlertPanelWithMessage: (NSString*)message 
    initiatedByFrame: (WebFrame*)frame
{
    NSLog(@"alert(\"%@\")", message);
    
//    UIAlertView *alertSheet = [[UIAlertView alloc] init];
//    [alertSheet setTitle: @"Override Javascript Alert"];
//    [alertSheet addButtonWithTitle: @"OK"];
//    [alertSheet setMessage:message];
//    [alertSheet setDelegate: self];
//    [alertSheet show];
}

- (BOOL) webView: (WebView*)webView runJavaScriptConfirmPanelWithMessage: (NSString*)message 
    initiatedByFrame: (WebFrame*)frame
{
    NSLog(@"confirm(%@)", message);
    
//    UIAlertView *alertSheet = [[UIAlertView alloc] init];
//    [alertSheet setTitle: @"Override Javascript Confirm"];
//    [alertSheet addButtonWithTitle: @"OK"];
//    [alertSheet addButtonWithTitle: @"Cancel"];    
//    [alertSheet setMessage:message];
//    [alertSheet setDelegate: self];
//    [alertSheet show];
//    return YES;
    return YES;
}

#  endif  // IPHONE_SDK_KOSHER
#endif // TARGET_IPHONE_SIMULATOR

// // GETS called, but the call to [super ...] fails. Which is weird, because it shows up in the
// // UIKit dylib
//- (void)webView:(id)webView runJavaScriptAlertPanelWithMessage:(id)message initiatedByFrame:(id)frame
//{
//    NSLog(@"got alert panel on webview %@: %@", webView, message);
//    // this doesn't work either; the respondsToSelector check passes, but the app crashes
//    if ([super respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:)]) {
//        NSLog(@"NEVER MIND, not sending alert panel msg to super");
//        // [super webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame];
//    }
//}

//- (BOOL) webView:(id)webView runJavaScriptConfirmPanelWithMessage:(id)message initiatedByFrame:(id)frame
//{
//    NSLog(@"got confirm panel with message: %@", message);
//    // XXX: for some reason if we call super here, we get a crash.  but if we don't
//    //     override this method, it executes!
//    [super webView:webView runJavaScriptConfirmPanelWithmessage:message initiatedByFrame:frame];
//    sleep(3);
//    return YES;
//}

//- (NSString *)webView:(WebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt 
//          defaultText:(NSString *)defaultText initiatedByFrame:(WebFrame *)frame;
//{
//    NSLog(@"got javascript text input panel with prompt %@", prompt);
//    // XXX: for some reason if we call super here, we get a crash.  but if we don't
//    //     override this method, it executes!
//    NSString *res = [super webView:sender runJavaScriptTextInputPanelWithPrompt:prompt 
//                       defaultText:defaultText
//                  initiatedByFrame:frame];
//
//    return res;
//}

//- (void)webView:(id)webView windowScriptObjectAvailable:(id)newWindowScriptObject {
//    NSLog(@"%@ received window ScriptObject %@", self, NSStringFromSelector(_cmd));
//
//    // save these goodies
//    windowScriptObject = newWindowScriptObject;
//    privateWebView = webView;
//
//    // enact any latent debugging settings
//    [self setScriptDebuggingEnabled:scriptDebuggingEnabled];
//
//    /* here we'll add our object to the window object as an object named
//     'nadirect'.  We can use this object in JavaScript by referencing the 'nadirect'
//     property of the 'window' object.   */
//
//    NSLog(@"scriptObject is %@", windowScriptObject);
////    [windowScriptObject setValue:[[NitroxApiDirectSystem alloc] initWithApp:app] forKey:@"nadirect"];
//}

// UNKNOWN
- (void)webView:(id)webView unableToImplementPolicyWithError:(id)error frame:(id)frame
{
    NSLog(@"webview=%@, webframe=%@ unable to implement policy with error: %@", 
          webView, frame, error);
}
















/*
 WebScriptCallFrame methods:
 
 32f5add0 t -[WebResourcePrivate dealloc]
 32f80b30 t -[WebScriptCallFrame caller]
 32f80a60 t -[WebScriptCallFrame dealloc]
 32f80c00 t -[WebScriptCallFrame evaluateWebScript:]
 32f80bd0 t -[WebScriptCallFrame exception]
 32f80ba0 t -[WebScriptCallFrame functionName]
 32f80b70 t -[WebScriptCallFrame scopeChain]
 32f80ac0 t -[WebScriptCallFrame setUserInfo:]
 32f80b20 t -[WebScriptCallFrame userInfo]
 
 
 00017 - (void)dealloc;
 00018 - (void)setUserInfo:(id)fp8;
 00019 - (id)userInfo;
 00020 - (id)caller;
 00021 - (id)scopeChain;
 00022 - (id)functionName;
 00023 - (id)exception;
 */

// some source was parsed, establishing a "source ID" (>= 0) for future reference
// this delegate method is deprecated, please switch to the new version below
//- (void)webView:(WebView *)webView       didParseSource:(NSString *)source
//        fromURL:(NSString *)url
//       sourceId:(int)sid
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called didParseSource; sid=%d, url=%@", sid, url);
//}

- (NSString *) webFrameInfo:(WebFrame *)frame
{
//    NSString *res =
//    [NSString stringWithFormat:@"[webFrame=%@, name=%@]",
//     frame, [frame name]];
//    
//    return res;
    return @"WebFrame";
}

- (NSString *) webViewInfo:(WebView *)view
{
//    NSString *res =
//    [NSString stringWithFormat:@"[webView=%@, URL=%@, title=%@]",
//     view, [view mainFrameURL], [view mainFrameTitle]];
//    
//    return res;
    return @"WebView";
}

//- (NitroxScriptDebugSourceInfo *) getSourceInfo:(int)sid
//{
//    NitroxScriptDebugSourceInfo *res = [sources objectForKey:[NSNumber numberWithInt:sid]];
//    return res;
//}

- (NSString *) getSourceInfo:(int)sid {
    return [NSString stringWithFormat:@"Source(%i)", sid];
}


// some source was parsed, establishing a "source ID" (>= 0) for future reference
- (void)webView:(WebView *)webView didParseSource:(NSString *)source baseLineNumber:(unsigned)lineNumber fromURL:(NSURL *)url sourceId:(int)sid forWebFrame:(WebFrame *)webFrame {

//    NSLog(@"NSDD: didParseSource: view=%@, sid=%d, line=%d, frame=%@, source=%@", [self webViewInfo:webView], sid, lineNumber, [self webFrameInfo:webFrame], url ? (id)url : (id)source);

    if (url) {
        NSLog(@"HE Parsed: %d %@", sid, url);        
        [self.scripts setObject:url forKey:[NSNumber numberWithInt:sid]];
    }
    
    else {
        NSLog(@"HE Parsed: %d %@", sid, source);        
    }
    
//    NSSelectorFromString(@"");
}

// some source failed to parse
- (void)webView:(WebView *)webView  failedToParseSource:(NSString *)source baseLineNumber:(unsigned)lineNumber fromURL:(NSURL *)url withError:(NSError *)error forWebFrame:(WebFrame *)webFrame {
    
//    NSLog(@"NSDD: called failedToParseSource: window=%@ url=%@ line=%d frame=%@ error=%@\nsource=%@", [self webViewInfo:webView], url, lineNumber, [self webFrameInfo:webFrame], error, source);
    NSLog(@"HEDebug: failedToParseSource: %@ exception: %@", url, error);    
    
}

// just entered a stack frame (i.e. called a function, or started global scope)
//- (void)webView:(WebView *)webView    didEnterCallFrame:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called didEnterCallFrame");
//}

// about to execute some code
//- (void)webView:(WebView *)webView willExecuteStatement:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called willEXecuteStatement");
//}

// about to leave a stack frame (i.e. return from a function)
//- (void)webView:(WebView *)webView   willLeaveCallFrame:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called willLeaveCallFrame");
//}

// exception is being thrown
- (void)webView:(WebView *)webView   exceptionWasRaised:(WebScriptCallFrame *)frame sourceId:(int)sid line:(int)lineno forWebFrame:(WebFrame *)webFrame {
    
//    NSLog(@"NSDD: exception: webView=%@, webFrame=%@, sid=%d line=%d function=%@, caller=%@, exception=%@, scopeChain=%@\nsource=%@", [self webViewInfo:webView], [self webFrameInfo:webFrame],sid, lineno, [frame functionName], [frame caller], [[frame exception] stringRepresentation], [frame scopeChain],[[self getSourceInfo:sid] description]);
    NSLog(@"HEDebug: exceptionWasRaised: sid=%d url=%@ line=%d", sid, [scripts objectForKey:[NSNumber numberWithInt:sid]], lineno); // [frame functionName] - doesn't work anyway
}

#endif

@end
