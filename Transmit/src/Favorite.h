#import <Cocoa/Cocoa.h>

#define TRItemProtocolFTP			@"FTP"
#define TRItemProtocolSFTP			@"SFTP"
#define TRItemProtocolFTPSSL		@"FTPSSL"
#define TRItemProtocolFTPTLS		@"FTPTLS"
#define TRItemProtocolWebDAV		@"WebDAV"
#define TRItemProtocolWebDAVS		@"WebDAVS"

//#define TRFavoriteChangedNotification		@"FavoriteChangedNotification"
//#define TRFavoritePasswordInKeychain		@"PasswordInKeychain"

typedef enum
{
	kNormalFavoriteType,
	kDotMacFavoriteType,
	kBonjourFavoriteType
} FavoriteType;


@interface Favorite : NSObject
{
	/*
		- When adding ivars do the following:
			- add getter/setter
			- add to initWithCoder
			- add to encodeWithCoder
			- if not an NSObject, add to init
			- add to dealloc
			- add to copy
	*/
	
	// values that aren't saved with the favorite
	
	NSImage	*image;
	NSMutableDictionary *syncEntity;
	
@private
	NSString *nickname;
	NSString *server;
	NSString *initialRemotePath;
	NSString *initialLocalPath;
	NSString *password;
	NSString *protocol;
	NSString *username;
	NSString *uuid;
	
	NSArray *localPathShortcuts;
	NSArray *remotePathShortcuts;
	
	int		stringEncoding;
	BOOL	folderLinkingEnabled;
	BOOL	passiveModeEnabled;
	BOOL	dockSendEnabled;
	int		port;
	BOOL	promptForPassword;
	BOOL	needsSyncing;
}

+ (id)favorite;

- (BOOL)isDockSendEnabled;
- (BOOL)isFolderLinkingEnabled;
- (NSString*)initialLocalPath;
- (NSString*)initialRemotePath;
- (NSArray*)localPathShortcuts;
- (BOOL)needsSyncing;
- (NSString*)nickname;
- (BOOL)isPassiveModeEnabled;
- (int)port;
- (BOOL)promptForPassword;
- (NSString*)protocol;
- (NSArray*)remotePathShortcuts;
- (NSString*)server;
- (int)stringEncoding;
- (NSString*)username;
- (NSString*)UUID;

- (void)setDockSendEnabled:(BOOL)flag;
- (void)setFolderLinkingEnabled:(BOOL)flag;
- (void)setImage:(NSImage*)anImage;
- (void)setInitialLocalPath:(NSString*)aPath;
- (void)setInitialRemotePath:(NSString*)aPath;
- (void)setLocalPathShortcuts:(NSArray*)paths;
- (void)setNeedsSyncing:(BOOL)flag;
- (void)setNickname:(NSString*)aName;
- (void)setPassiveModeEnabled:(BOOL)flag;
- (void)setPassword:(NSString*)aPassword;
- (void)setPort:(int)aPort;
- (void)setPromptForPassword:(BOOL)flag;
- (void)setProtocol:(NSString*)aProtocol;
- (void)setRemotePathShortcuts:(NSArray*)paths;
- (void)setServer:(NSString*)aServer;
- (void)setStringEncoding:(int)encoding;
- (void)setUsername:(NSString*)aName;
- (void)setUUID:(NSString*)newUUID;

//- (void)fetchFavIcon;
- (FavoriteType)type;

@end

//@interface Favorite (Private)
//- (BOOL)savePasswordInKeychain;
//- (NSString*)passwordFromKeychain;
//@end
