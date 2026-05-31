#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADSDarkEngine : NSObject

@property (nonatomic, copy, readonly) NSString *modeLabel;
@property (nonatomic, copy, readonly) NSArray<NSString *> *moduleNames;
@property (nonatomic, copy, readonly) NSArray<NSDictionary<NSString *, id> *> *moduleInventory;

- (NSArray<NSArray<NSString *> *> *)dryRunStages;
- (BOOL)runRealExploit;

@end

NS_ASSUME_NONNULL_END
