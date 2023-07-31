
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNImageOriginalTimestampSpec.h"

@interface ImageOriginalTimestamp : NSObject <NativeImageOriginalTimestampSpec>
#else
#import <React/RCTBridgeModule.h>

@interface ImageOriginalTimestamp : NSObject <RCTBridgeModule>
#endif

@end
