/* types and IDs for objects */
#define HRMediaRoot				@"QSPresetHomestarRunnerMedia"
#define HRSBEmailList			@"com.homestarrunner.sbemail.list"
#define HRSBEmailItem			@"com.homestarrunner.sbemail"
#define HRSBEmailViewer			@"com.homestarrunner.sbemail.viewer"
#define HRSBEmailFlash			@"com.homestarrunner.sbemail.flash"
#define HRSBEmailListID			@"com.homestarrunner.sbemail.list"
#define HRSBEmailItemID			@"com.homestarrunner.sbemail.%@"
#define HRSBEmailViewerID		@"com.homestarrunner.sbemail.%@.viewer"
#define HRSBEmailFlashID		@"com.homestarrunner.sbemail.%@.flash"
#define HRCharacterList			@"com.homestarrunner.cast.list"
#define HRCharacterItem			@"com.homestarrunner.cast.item"
#define HRCharacterListID		@"com.homestarrunner.cast.list"
#define HRCharacterItemID		@"com.homestarrunner.cast.%@"

/* paths to icons */
#define HRIconHomestar			@"homestar"
#define HRIconStrongBad			@"strongbad"
#define HRIconTheCheat			@"thecheat"
#define HRIconStrongMad			@"strongmad"
#define HRIconStrongSad			@"strongsad"
#define HRIconMarzipan			@"marzipan"
#define HRIconCoachZ			@"coachz"
#define HRIconPomPom			@"pompom"
#define HRIconBubs				@"bubs"
#define HRIconThePoopsmith		@"poopsmith"
#define HRIconTheKingOfTown		@"kingoftown"
#define HRIconHomsar			@"homsar"
#define HRIconTrogdor			@"bonus-trogdor"
#define HRIconStinkoman			@"bonus-stinkoman"
#define HRIconMarshie			@"bonus-marshie"
#define HRIconPanPan			@"panpan"
#define HRIconSBHead			@"strongbadhead"
#define HRIconEmail				@"mailto"

/* locations */
#define URL(k)					[NSURL URLWithString:k]
#define HRWikiBase				@"http://www.hrwiki.org"
#define HRWikiSBEmailList		@"http://www.hrwiki.org/index.php/Strong_Bad_Email"
#define HRTempItem				@"/tmp/%@.html"

/* patterns */
#define HRWikiSBEmailLinkPat	@"(\\d+)\\.\\s*<a\\s+href\\s*=\\s*\"([^\"]*)\"[^>]*>([^<]*)"
#define HRWikiExternalLinkPat   @"<a\\s+href\\s*=\\s*'([^']*)'\\s+class\\s*=\\s*'external'[^>]*>"
#define HRWikiCastStart			@"Cast (in order of appearance):"
#define HRWikiCastEnd			@"</p>"
#define HRWikiLinkPat			@"<a\\s+href\\s*=\\s*\"([^\"]*)\"[^>]*>\\s*([^<]*?)\\s*<"
#define HRWikiSBEmailStart		@"<pre>"
#define HRWikiSBEmailEnd		@"</pre>"
#define HRWikiArticleListStart  @"<table"
#define HRWikiArticleListEnd	@"</table>"

/* group numbers */
#define kHRSBEmailGroupIndex	1
#define kHRSBEmailGroupURL		2
#define kHRSBEmailGroupName		3
#define kHRSBEmailGroupEntry	1
#define kHRLinkGroupURL			1
#define kHRLinkGroupName		2

/* other numerical constants */
#define kHRTimeoutEmailItem		7*24*60*60
#define kHRTimeoutEmailList		24*60*60

/* character names */
#define HRHomestarRunner		@"Homestar"
#define HRStrongBad				@"Strong Bad"
#define HRTheCheat				@"The Cheat"
#define HRStrongMad				@"Strong Mad"
#define HRStrongSad				@"Strong Sad"
#define HRMarzipan				@"Marzipan"
#define HRCoachZ				@"Coach Z"
#define HRPomPom				@"Pom Pom"
#define HRBubs					@"Bubs"
#define HRThePoopsmith			@"The Poopsmith"
#define HRTheKingOfTown			@"The King of Town"
#define HRHomsar				@"Homsar"
#define HRTrogdor				@"Trogdor"
#define HRStinkoman				@"Stinkoman"
#define HRMarshie				@"Marshie"
#define HRPanPan				@"Pan Pan"