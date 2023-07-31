#import "ImageOriginalTimestamp.h"

#import <Photos/Photos.h>

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
          } else {
              AVURLAsset *avURLAsset = (AVURLAsset*)contentEditingInput.audiovisualAsset;
              imageURL = [avURLAsset URL];
          }
            
            CIImage *imageObject = [[CIImage alloc] initWithContentsOfURL:imageURL];
            NSDictionary *exif = imageObject.properties[@"{Exif}"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
            NSDate *dateOriginal = [dateFormat dateFromString:exif[@"DateTimeOriginal"]];
            resolve(@(dateOriginal.timeIntervalSince1970));
        }];
    }else {
        reject(@"Error", @"Image Fetch Error", nil);
    }
    }
    @catch(NSException *e){
        reject(e.name, e.reason, nil);
    }
}

@end
