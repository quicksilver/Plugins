-(NSArray *)trackInfoForIDs:(NSArray *)theIDs {
	NSMutableArray *tracks = [NSMutableArray array];
	foreach(theID, theIDs) {
		id track = [self trackInfoForID:theID];
		if (track) [tracks addObject:track];
	}
	return tracks;
}
