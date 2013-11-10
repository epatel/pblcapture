#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE;

static void (^MyHTTPConnection_updateBlock)(NSDictionary *update) = nil;

@implementation MyHTTPConnection

+ (void)setUpdateBlock:(void (^)(NSDictionary *update))updateBlock
{
    MyHTTPConnection_updateBlock = [updateBlock copy];
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	if ([method isEqualToString:@"POST"])
        return YES;
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	if ([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	if ([method isEqualToString:@"POST"] && MyHTTPConnection_updateBlock) {

		NSData *postData = [request body];
		if (postData ) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:postData options:0 error:nil];
            if ([dict isKindOfClass:[NSDictionary class]]) {
                MyHTTPConnection_updateBlock(dict);
            }
        }

		return [[HTTPDataResponse alloc] initWithData:[@"Received\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	// If we supported large uploads,
	// we might use this method to create/open files, allocate memory, etc.
}

- (void)processBodyData:(NSData *)postDataChunk
{	
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	BOOL result = [request appendData:postDataChunk];
	if (!result) {
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
}

@end
