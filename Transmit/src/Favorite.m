#import "Favorite.h"

#import "LocaleMacros.h"


@implementation Favorite


+ (id)favorite
{
	return [[[Favorite alloc] init] autorelease];
}


- (Favorite*)initWithCoder:(NSCoder*)coder
{
	self = [super init];
	
	if ( self )
	{
		nickname = [[coder decodeObjectForKey:@"nickname"] retain];
		server = [[coder decodeObjectForKey:@"server"] retain];
		initialRemotePath = [[coder decodeObjectForKey:@"initialRemotePath"] retain];
		initialLocalPath = [[coder decodeObjectForKey:@"initialLocalPath"] retain];
		password = [[coder decodeObjectForKey:@"password"] retain];
		protocol = [[coder decodeObjectForKey:@"protocol"] retain];
		username = [[coder decodeObjectForKey:@"username"] retain];
		localPathShortcuts = [[coder decodeObjectForKey:@"localPathShortcuts"] retain];
		remotePathShortcuts = [[coder decodeObjectForKey:@"remotePathShortcuts"] retain];
		uuid = [[coder decodeObjectForKey:@"uuid"] retain];
		
		stringEncoding = [coder decodeIntForKey:@"stringEncoding"];
		folderLinkingEnabled = [coder decodeBoolForKey:@"folderLinkingEnabled"];
		passiveModeEnabled = [coder decodeBoolForKey:@"passiveModeEnabled"];
		dockSendEnabled = [coder decodeBoolForKey:@"dockSendEnabled"];																
		port = [coder decodeIntForKey:@"port"];
		promptForPassword = [coder decodeBoolForKey:@"promptForPassword"];
		
		// needed to upgrade favorites from 3.1 format to 3.2 format
		
		//if ( uuid == nil )
		//	[self setUUID:[NSString UUIDString]];
		
		needsSyncing = [coder decodeBoolForKey:@"needsSyncing"];
	}
	
	return self;
}


- (void)dealloc
{
	[nickname release];
	[server release];
	[initialRemotePath release];
	[initialLocalPath release];
	[password release];
	[protocol release];
	[username release];
	[uuid release];
	
	[localPathShortcuts release];
	[remotePathShortcuts release];

	[image release];
	[syncEntity release];
		
	[super dealloc];
}


- (BOOL)isDockSendEnabled
{
	return dockSendEnabled;
}


- (BOOL)isFolderLinkingEnabled
{
	return folderLinkingEnabled;
}


- (NSString*)initialLocalPath
{
	return initialLocalPath;
}


- (NSString*)initialRemotePath
{
	return initialRemotePath;
}


- (NSArray*)localPathShortcuts
{
	return localPathShortcuts;
}


- (BOOL)needsSyncing
{
	return NO;
}


- (NSString*)nickname
{
	return nickname;
}


- (BOOL)isPassiveModeEnabled
{
	return passiveModeEnabled;
}


- (int)port
{
	return port;
}


- (BOOL)promptForPassword
{
	return promptForPassword;
}


- (NSString*)protocol
{
	return protocol;
}


- (NSArray*)remotePathShortcuts
{
	return remotePathShortcuts;
}


- (NSString*)server
{
	return server;
}


- (int)stringEncoding
{
	return stringEncoding;
}


- (NSString*)username
{
	return username;
}


- (NSString*)UUID
{
	return uuid;
}


- (void)setDockSendEnabled:(BOOL)flag
{
	dockSendEnabled = flag;
}


- (void)setFolderLinkingEnabled:(BOOL)flag
{
	folderLinkingEnabled = flag;
}


- (void)setImage:(NSImage*)anImage
{
	[image autorelease];
	image = [anImage retain];
}

- (void)setInitialLocalPath:(NSString*)aPath
{
	[initialLocalPath autorelease];
	initialLocalPath = [aPath retain];
}


- (void)setInitialRemotePath:(NSString*)aPath
{
	[initialRemotePath autorelease];
	initialRemotePath = [aPath retain];
}


- (void)setLocalPathShortcuts:(NSArray*)paths
{
	[localPathShortcuts autorelease];
	localPathShortcuts = [paths retain];
}


- (void)setNeedsSyncing:(BOOL)flag
{
	needsSyncing = flag;
}


- (void)setNickname:(NSString*)aName
{
	NSAssert(aName != nil, @"Favorite: nickname must be non-nil");
	
	[nickname autorelease];
	nickname = [aName retain];
}


- (void)setPassiveModeEnabled:(BOOL)flag
{
	passiveModeEnabled = flag;
}


- (void)setPassword:(NSString*)aPassword
{	
	[password autorelease];
	password = [aPassword retain];
}


- (void)setPort:(int)aPort
{
	port = aPort;
}


- (void)setPromptForPassword:(BOOL)flag
{
	if ( flag )
		[self setPassword:@""];
	
	promptForPassword = flag;
}


- (void)setProtocol:(NSString*)aProtocol
{
	[protocol autorelease];
	protocol = [aProtocol retain];
}


- (void)setRemotePathShortcuts:(NSArray*)paths
{
	[remotePathShortcuts autorelease];
	remotePathShortcuts = [paths retain];
}


- (void)setServer:(NSString*)aServer
{
	NSAssert(aServer != nil, @"Favorite: server must be non-nil");

	[server autorelease];
	server = [aServer retain];
}


- (void)setStringEncoding:(int)encoding
{
	stringEncoding = encoding;
}


- (void)setUsername:(NSString*)aName
{
	[username autorelease];
	username = [aName retain];
}


- (void)setUUID:(NSString*)newUUID
{
	[uuid autorelease];
	uuid = [newUUID retain];
}


- (FavoriteType)type
{
	return kNormalFavoriteType;
}

@end