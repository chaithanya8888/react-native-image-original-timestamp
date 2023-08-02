#import "ImageOriginalTimestamp.h"

#import <Photos/Photos.h>
#import <Foundation/Foundation.h>

@implementation ImageOriginalTimestamp
RCT_EXPORT_MODULE()

// Example method
// See // https://reactnative.dev/docs/native-modules-ios
RCT_EXPORT_METHOD(fetchTimeStamp:(NSString *)internalId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    @try {
    PHFetchResult<PHAsset *> *fetchResult;
    PHAsset *asset;
    NSString *mediaIdentifier = internalId;

    if ([internalId rangeOfString:@"ph://"].location != NSNotFound) {
      mediaIdentifier = [internalId stringByReplacingOccurrencesOfString:@"ph://"
                                                                   withString:@""];
    }

    fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[mediaIdentifier] options:nil];
    if(fetchResult){
      asset = fetchResult.firstObject;//only object in the array.
    }
    if(asset){
        PHContentEditingInputRequestOptions *const editOptions = [PHContentEditingInputRequestOptions new];
        // Download asset if on icloud.
        editOptions.networkAccessAllowed = YES;

        [asset requestContentEditingInputWithOptions:editOptions completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
            __block NSURL *imageURL = [[NSURL alloc]initWithString:@""];
          if (asset.mediaType == PHAssetMediaTypeImage) {
              imageURL = contentEditingInput.fullSizeImageURL;
              CIImage *imageObject = [[CIImage alloc] initWithContentsOfURL:imageURL];
              NSDictionary *exif = imageObject.properties[@"{Exif}"];
              NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
              [dateFormat setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
              NSDate *dateOriginal = [dateFormat dateFromString:exif[@"DateTimeOriginal"]];
              resolve(@(dateOriginal.timeIntervalSince1970));
          } else {
              AVURLAsset *avURLAsset = (AVURLAsset*)contentEditingInput.audiovisualAsset;
              imageURL = [avURLAsset URL];
              NSArray *metadata = avURLAsset.metadata;
              for (AVMetadataItem *metadataItem in metadata) {
                if ([metadataItem.commonKey isEqual:@"creationDate"]) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                    NSString *dateString = metadataItem.value;
                    NSRange range = [dateString rangeOfString:@"+"];

                    // If the `+` character is found, remove everything after it from the string.
                    if (range.location != NSNotFound) {
                        dateString = [dateString substringToIndex:range.location];
                    }

                    // Convert the date string to a NSDate object.
                    NSDate *date = [formatter dateFromString:dateString];

                    // Get the timestamp for the date.
                    NSTimeInterval timestamp = [date timeIntervalSince1970];
                    resolve(@(timestamp));
                    return;
                }
              }
              reject(@"Error", @"Media Fetch Error", nil);
          }
        }];
    }else {
        reject(@"Error", @"Media Fetch Error", nil);
    }
    }
    @catch(NSException *e){
        reject(e.name, e.reason, nil);
    }
}

@end
