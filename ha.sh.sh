cat > /tmp/p.py << 'EOF'
import re
path = '/home/makar/AntiDarkSword/ADSRootViewController.m'
content = open(path).read()

old_start = '            // 4. Сканирование через POSIX (не NSFileManager!)'
old_end = '            } // end else'

i1 = content.index(old_start)
i2 = content.index(old_end) + len(old_end)

new = '''            // 4. Поиск: LSApplicationWorkspace → fallback 2-level POSIX
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendLog:@"[*] Locating com.axlebolt.standoff2..."];
            });
            self.foundGamePath = nil;

            // Метод 1: LSApplicationWorkspace (мгновенно)
            {
                Class LSAppWorkspace = NSClassFromString(@"LSApplicationWorkspace");
                if (LSAppWorkspace) {
                    id ws = [LSAppWorkspace performSelector:NSSelectorFromString(@"defaultWorkspace")];
                    if (ws) {
                        id proxy = [ws performSelector:NSSelectorFromString(@"applicationProxyForIdentifier:")
                                           withObject:@"com.axlebolt.standoff2"];
                        if (proxy) {
                            NSURL *burl = [proxy performSelector:NSSelectorFromString(@"bundleURL")];
                            if (burl) {
                                NSString *info = [burl.path stringByAppendingPathComponent:@"Info.plist"];
                                if ([[NSFileManager defaultManager] fileExistsAtPath:info]) {
                                    self.foundGamePath = info;
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self appendLog:[NSString stringWithFormat:@"[+] LSApp: %@", info]];
                                    });
                                }
                            }
                        }
                    }
                }
            }

            // Метод 2: 2-уровневый POSIX fallback
            if (!self.foundGamePath) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self appendLog:@"[*] Fallback: 2-level POSIX scan..."];
                });
                const char *bases[] = {
                    "/private/var/containers/Bundle/Application",
                    "/var/containers/Bundle/Application",
                    NULL
                };
                for (int b = 0; bases[b] && !self.foundGamePath; b++) {
                    DIR *d1 = opendir(bases[b]);
                    if (!d1) continue;
                    struct dirent *e1;
                    while ((e1 = readdir(d1)) != NULL && !self.foundGamePath) {
                        if (e1->d_name[0] == '.') continue;
                        char lvl1[512];
                        snprintf(lvl1, sizeof(lvl1), "%s/%s", bases[b], e1->d_name);
                        DIR *d2 = opendir(lvl1);
                        if (!d2) continue;
                        struct dirent *e2;
                        while ((e2 = readdir(d2)) != NULL && !self.foundGamePath) {
                            if (e2->d_name[0] == '.') continue;
                            char ip[1024];
                            snprintf(ip, sizeof(ip), "%s/%s/Info.plist", lvl1, e2->d_name);
                            NSDictionary *pl = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithUTF8String:ip]];
                            if ([[pl objectForKey:@"CFBundleIdentifier"] isEqualToString:@"com.axlebolt.standoff2"]) {
                                self.foundGamePath = [NSString stringWithUTF8String:ip];
                                NSString *fp = self.foundGamePath;
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self appendLog:[NSString stringWithFormat:@"[+] POSIX: %@", fp]];
                                });
                            }
                        }
                        closedir(d2);
                    }
                    closedir(d1);
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.foundGamePath)
                    [self appendLog:@"[-] com.axlebolt.standoff2 not found"];
                UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
                [copyBtn setTitle:@"\\U0001F4CB" forState:UIControlStateNormal];
                copyBtn.titleLabel.font = [UIFont systemFontOfSize:22];
                copyBtn.frame = CGRectMake(self.view.bounds.size.width - 50, 50, 44, 44);
                copyBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                copyBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
                copyBtn.layer.cornerRadius = 22;
                [copyBtn addTarget:self action:@selector(copyLogs) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:copyBtn];
            });'''

result = content[:i1] + new + content[i2:]
open(path, 'w').write(result)
print('OK: replaced %d chars with %d chars' % (i2-i1, len(new)))
EOF
python3 /tmp/p.py