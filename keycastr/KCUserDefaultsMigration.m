//  Copyright (c) 2024 Andrew Kitchen
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  *    Redistributions of source code must retain the above copyright notice, this
//      list of conditions and the following disclaimer.
//  *    Redistributions in binary form must reproduce the above copyright notice,
//      this list of conditions and the following disclaimer in the documentation
//      and/or other materials provided with the distribution.
//  *    Neither the name KeyCastr nor the names of its contributors may be used to
//      endorse or promote products derived from this software without specific
//      prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KCUserDefaultsMigration.h"

@implementation KCUserDefaultsMigration

// TODO: migrate legacy keys from dot/namespaces to underscores, and audit for observation (KVC?)

+ (void)performMigration:(NSUserDefaults *)userDefaults {
    // Only migrate if we're running on macOS 10.14 or later or the user may lose their color preference
    if (@available(macOS 10.14, *)) {
        NSArray *colorKeyNames = [self colorKeyNames];
        for (NSString *colorKey in colorKeyNames) {
            NSData *colorData = [userDefaults dataForKey:colorKey];
            if (!colorData) {
                continue;
            }

            // If the color can be unarchived by the deprecated unarchiver,
            // we need to convert it.
            NSColor *color = [NSUnarchiver unarchiveObjectWithData:colorData];
            if (color) {
                NSData *newColorData = [NSKeyedArchiver archivedDataWithRootObject:color
                                                             requiringSecureCoding:NO
                                                                             error:NULL];
                [userDefaults setObject:newColorData forKey:colorKey];
            }
        }
    }

    [userDefaults removeObjectForKey:@"svelte.allKeystrokes"];
}

+ (NSArray *)colorKeyNames {
    return @[ @"default.textColor", @"default.bezelColor" ];
}

@end
