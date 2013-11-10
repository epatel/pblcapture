#import "HTTPConnection.h"

@interface MyHTTPConnection : HTTPConnection

+ (void)setUpdateBlock:(void (^)(NSDictionary *update))updateBlock;

@end
