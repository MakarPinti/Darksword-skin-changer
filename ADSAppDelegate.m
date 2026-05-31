#import "ADSAppDelegate.h"
#import "ADSRootViewController.h"

@implementation ADSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [ADSRootViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
