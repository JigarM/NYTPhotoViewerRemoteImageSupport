//
//  NYTExamplePhoto.h
//  ios-photo-viewer
//
//  Created by Brian Capps on 2/11/15.
//  Copyright (c) 2015 NYTimes. All rights reserved.
//

@import Foundation;
@import UIKit;

//#import "NYTPhotoViewer/Protocols/NYTPhoto.h"

@interface NYTExamplePhoto : NSObject

// Redeclare all the properties as readwrite for sample/testing purposes.
@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;
@property (nonatomic) NSString *remoteURL;
@end
