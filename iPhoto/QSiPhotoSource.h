


#import <Cocoa/Cocoa.h>
#import <QSCore/QSCore.h>

#define QSiPhotoAlbumPboardType @"qs.apple.iPhoto.album"
#define QSiPhotoPhotoType @"qs.apple.iPhoto.photo"

@interface QSiPhotoObjectSource : QSObjectSource{
    NSDictionary *iPhotoLibrary;
}

- (NSDictionary *)iPhotoLibrary;
- (void)setiPhotoLibrary:(NSDictionary *)newiPhotoLibrary;
@end

@interface QSiPhotoActionProvider : QSActionProvider{
    NSAppleScript *iPhotoScript;
}
- (NSAppleScript *)iPhotoScript;
@end
