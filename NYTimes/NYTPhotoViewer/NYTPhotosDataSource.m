//
//  NYTPhotosDataSource.m
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/11/15.
//
//

#import "NYTPhotosDataSource.h"
#import "NYTPhoto.h"

@interface NYTPhotosDataSource ()

@property (nonatomic, copy) NSMutableArray *photos;

@end

@implementation NYTPhotosDataSource

#pragma mark - NSObject

- (instancetype)init {
    return [self initWithPhotos:nil];
}

#pragma mark - NYTPhotosDataSource

- (instancetype)initWithPhotos:(NSArray *)photos {
    self = [super init];
    
    if (self) {
        _photos = photos.mutableCopy;
    }
    
    return self;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)length {
    return [self.photos countByEnumeratingWithState:state objects:buffer count:length];
}

#pragma mark - NYTPhotosViewControllerDataSource

- (NSUInteger)numberOfPhotos {
    return self.photos.count;
}

- (NYTPhoto *)photoAtIndex:(NSUInteger)photoIndex {
    if (photoIndex < self.photos.count) {
        return self.photos[photoIndex];
    }
    
    return nil;
}

- (NSUInteger)indexOfPhoto:(NYTPhoto *)photo {
    return [self.photos indexOfObject:photo];
}

- (BOOL)containsPhoto:(NYTPhoto *)photo {
    return [self.photos containsObject:photo];
}

- (NYTPhoto *)objectAtIndexedSubscript:(NSUInteger)photoIndex {
    return [self photoAtIndex:photoIndex];
}

- (void)removePhotoAtIndex:(NSUInteger)photoIndex {
    if (photoIndex < self.numberOfPhotos) {
        [self.photos removeObjectAtIndex:photoIndex];
    }
}

- (void)appendPhotos:(NSArray<NYTPhoto *> *)photos {
    self.photos = [self.photos arrayByAddingObjectsFromArray:photos] ?: photos;
}

@end
