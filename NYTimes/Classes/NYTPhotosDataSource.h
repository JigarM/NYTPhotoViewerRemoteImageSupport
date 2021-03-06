//
//  NYTPhotosDataSource.h
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/11/15.
//
//

@import Foundation;

#import "NYTPhotosViewControllerDataSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  A concrete implementation of the `NYTPhotosViewControllerDataSource`.
 */
@interface NYTPhotosDataSource : NSObject <NYTPhotosViewControllerDataSource>

/**
 *  The designated initializer that takes and stores an array of photos.
 *
 *  @param photos An array of objects conforming to the `NYTPhoto` protocol.
 *
 *  @return A fully initialized object.
 */
- (instancetype)initWithPhotos:(nullable NSArray *)photos NS_DESIGNATED_INITIALIZER;

/**
 *  Adds more photos to the end of the list.
 *
 *  @param photos The new photos to add to the end of the array of current photos.
 */
- (void)appendPhotos:(NSArray<NYTPhoto*> *)photos;


@end

NS_ASSUME_NONNULL_END
