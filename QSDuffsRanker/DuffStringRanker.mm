#import <algorithm>
#import <vector>
#import <cctype>
#import "DuffStringRanker.h"

#define IGNORED_SCORE 0.9

UniChar to_lower (UniChar ch)
{
	if((ch & ~0x7f) == 0)
		return tolower(ch);

	UniChar res = ch;

	CFStringRef tmp = CFStringCreateWithCharacters(NULL, &ch, 1);
	CFMutableStringRef strRef = CFStringCreateMutableCopy(NULL, 0, tmp);
	CFStringLowercase(strRef, NULL);

	CFIndex len = CFStringGetLength(strRef);
	if(len == 1)
		CFStringGetCharacters(strRef, CFRangeMake(0, 1), &res);

	CFRelease(strRef);
	CFRelease(tmp);

	return res;
}

struct unichar_string
{
	UniChar* bytes;
	CFIndex length;
	bool did_allocate_bytes;

	unichar_string (NSString* str) : did_allocate_bytes(false)
	{
		length = [str length];
		if(!(bytes = (UniChar*)CFStringGetCharactersPtr((CFStringRef)str)))
		{
			bytes = new UniChar[length];
			[str getCharacters:bytes];
			did_allocate_bytes = true;
		}
	}

	~unichar_string ()
	{
		if(did_allocate_bytes)
			delete[] bytes;
	}

	UniChar* begin () const		{ return bytes; }
	UniChar* end () const		{ return bytes + length; }
};

template <typename _OutputIter>
void create_decompose_map (UniChar* first1, UniChar* last1, UniChar* first2, UniChar* last2, _OutputIter map)
{
	unsigned index = 0;
	for(; first1 != last1 && first2 != last2; ++first2)
	{
		*map++ = index;
		if(*first1 == *first2 || !CFCharacterSetIsCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetNonBase), *first2))
			++index, ++first1;
	}

	for(; first2 != last2; ++first2)
		*map++ = index;
}

template <typename _OutputIter1, typename _OutputIter2>
_OutputIter1 normalize_string (UniChar* it, UniChar* last, _OutputIter1 out, _OutputIter2 orgIndex)
{
	int prev_was_space = 1;
	int prev_was_uppercase = 0;
	unsigned index = 0;
	*out++ = ' ';
	*orgIndex++ = index;
	for(; it != last; ++it, ++index, prev_was_space >>= 1, prev_was_uppercase >>= 1)
	{
		if(CFCharacterSetIsCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetNonBase), *it))
		{
			prev_was_space <<= 1;
			prev_was_uppercase <<= 1;
		}
		else if(CFCharacterSetIsCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetUppercaseLetter), *it))
		{
			if(!prev_was_space && !prev_was_uppercase)
			{
				*out++ = ' ';
				*orgIndex++ = index;
			}
			*out++ = to_lower(*it);
			*orgIndex++ = index;

			prev_was_uppercase = 2;
		}
		else if(CFCharacterSetIsCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetAlphaNumeric), *it))
		{
			*out++ = *it;
			*orgIndex++ = index;
		}
		else if(*it != '.' && *it != '\'' && !prev_was_space && it+1 != last)
		{
			*out++ = ' ';
			*orgIndex++ = index;
			prev_was_space = 2;
		}
		else
		{
			prev_was_space <<= 1;
			prev_was_uppercase <<= 1;
		}
	}
	return out;
}

bool is_subset (UniChar* first1, UniChar* last1, UniChar* first2, UniChar* last2)
{
	while(first1 != last1 && first2 != last2)
	{
		first1 = std::find(first1, last1, *first2);
		if(first1 != last1)
			++first1, ++first2;
	}
	return first2 == last2;
}

double calculate_score (UniChar* first1, UniChar* last1, UniChar* first2, UniChar* last2, double point = 1.0, double bonus = 0.5, unsigned* indices = NULL, int index = 0)
{
	double score_1 = -1.0, score_2 = 0.0;
	if(first2 != last2)
	{
		UniChar const upcased[] = { ' ', *first2 };
		UniChar* uppercase = std::search(first1, last1, upcased, upcased+2);
		if(is_subset(uppercase, last1, first2, last2))
			score_1 = point + bonus + calculate_score(uppercase+2, last1, first2+1, last2, point, 0.5 * bonus);

		UniChar* lowercase = std::find(first1, last1, *first2);
		if(lowercase != uppercase)
			score_2 = calculate_score(lowercase+1, last1, first2+1, last2, point, 0.5 * bonus);

		if(indices)
		{
			if(score_2 > score_1)
			{
				index += lowercase - first1;
				*indices++ = index;
				calculate_score(lowercase+1, last1, first2+1, last2, point, 0.5 * bonus, indices, index+1);
			}
			else
			{
				index += uppercase+1 - first1;
				*indices++ = index;
				calculate_score(uppercase+2, last1, first2+1, last2, point, 0.5 * bonus, indices, index+1);
			}
		}
	}
	return std::max(score_1, score_2);
}

double substring_score (UniChar* first1, UniChar* last1, UniChar* first2, UniChar* last2, double point = 1.0)
{
	double res = 0.0;

	while(first1 != last1 && last2 - first2 > 1)
	{
		UniChar* candidate = std::find(first1, last1, *first2);
		if(candidate == last1 || !is_subset(candidate, last1, first2, last2))
			break;

		if(candidate+1 == last1 || candidate[1] != first2[1])
		{
			first1 = candidate+1;
			continue;
		}

		double score = 0;
		while(candidate != last1 && first2 != last2 && *candidate == *first2)
		{
			score += point;
			++candidate, ++first2;
		}

		first1 = candidate;
		score += substring_score(first1, last1, first2, last2, point);
		res = std::max(score, res);
	}
	return res;
}

@implementation DuffStringRanker
- (id)initWithString:(NSString *)aString
{
	if(!(self = [super init]))
		return nil;

//	NSLog(@"%s %@", _cmd, aString);

	CFMutableStringRef tmpStr = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, (CFStringRef)aString);
	if(!tmpStr)
		return (id)([self release], nil);

	[self setValue:aString forKey:@"originalString"];

	CFStringNormalize(tmpStr, kCFStringNormalizationFormD);
	unichar_string pStr(aString), dStr((NSString*)tmpStr);

	if(pStr.length > dStr.length || pStr.length == 0)
	{
	//	NSLog(@"*** decomposed string shorter: %@ (%u > %u)", aString, pStr.length, dStr.length);
		CFRelease(tmpStr);
		[self release];
		return nil;
	}

	std::vector<unsigned> map;
	create_decompose_map(pStr.begin(), pStr.end(), dStr.begin(), dStr.end(), back_inserter(map));

	std::vector<UniChar> nStr;
	std::vector<unsigned> orgIndex;
	normalize_string(dStr.begin(), dStr.end(), back_inserter(nStr), back_inserter(orgIndex));
	length = nStr.size();

	string = new UniChar[length];
	std::copy(nStr.begin(), nStr.end(), string);

	originalIndex = new unsigned[length];
	for(unsigned int i = 0; i != length; i++)
		originalIndex[i] = map[orgIndex[i]];

	CFRelease(tmpStr);
	[self setRankedString:aString];
	return self;
}

- (void)dealloc
{
	[self setValue:nil forKey:@"originalString"];
	[rankedString release];
	delete[] string;
	delete[] originalIndex;
	[super dealloc];
}
/*

	Entering: A
1	 Abcdef
2	 Ax Bcdef
2	 Ab CDef
3	 Ax Bcdef Def
3	 Ab CDef Def
4	 x Abcdef
5	 x A Bcdef
5	 x Ab CDef
6	 x Ax Bcdef Def
6	 x Ab CDef Def
7	 x y Abcdef
8	 x y A Bcdef
8	 x y Ab CDef
9	 x y Ax Bcdef Def
9	 x y Ab CDef Def

	Entering: AB
1	 Ax Bcdef       2/2 -0.5/2
2	 Abcdef         1/2  1.5/2
4	 Ab CDef        1/2  1.5/2
3	 Ax Bcdef Def   2/3 -0.5/3
5	 Ab CDef Def    1/3  1.5/3
6	 x A Bcdef
7	 x Abcdef
8	 x Ax Bcdef Def
9	 x Ab CDef
10  x Ab CDef Def
11  x y A Bcdef
12  x y Abcdef
13  x y Ax Bcdef Def
14  x y Ab CDef
15  x y Ab CDef Def

	1. first word match: (m-n)/m    -- n is index of first word touched
   2. max of:
	 2a. words touched: n/m         -- n is words touched
	 2b. substring length: (n-.5)/m -- n is length of substring



*/
- (double)scoreForAbbreviation:(NSString*)anAbbreviation
{
//	NSLog(@"%s %@", _cmd, anAbbreviation);

	unichar_string str(anAbbreviation);
	if(str.length == 0 || !is_subset(string, string + length, str.begin(), str.end()))
		return IGNORED_SCORE;

	double len = str.length;
	double unit = 1.0 / (len+1.0);

	double score = calculate_score(string, string + length, str.begin(), str.end(), unit, 0.5 * unit);
	double s_score = substring_score(string, string + length, str.begin(), str.end(), unit);

//	printf("%s: max(%.3f, %.3f) %s\n", [anAbbreviation UTF8String], score, s_score, [originalString UTF8String]);

	score = std::max(score, s_score);
	if(std::search(string, string + length, str.begin(), str.end()) != string + length)
		score += 1.0 / ((len+1.0) * pow(2, len+1.0));

	if(string[1] == str.bytes[0])
		score += 1.0 / ((len+1.0) * pow(2, len+2.0));

	double words = (double)std::count(string, string + length, ' ');
	score += (score / (unit * (words+1))) * (1.0 / ((len+1.0) * pow(2, len+3.0)));

	// fix score for current QS
	score = .66*score + .34;
//	NSLog(@"%.3f: %@", score, originalString);

	return score;
}

- (NSIndexSet*)maskForAbbreviation:(NSString*)anAbbreviation
{
	unichar_string str(anAbbreviation);
	if(str.length == 0 || !is_subset(string, string + length, str.begin(), str.end()))
		return nil;

	unsigned indices[str.length];
	calculate_score(string, string + length, str.begin(), str.end(), 1.0, 0.5, indices);

	NSMutableIndexSet* res = [[NSMutableIndexSet new] autorelease];
	for(int i = 0; i != str.length; i++)
		[res addIndex:originalIndex[indices[i]]];

	return res;
}

- (NSString*)rankedString
{
	return rankedString;
}

- (void)setRankedString:(NSString*)aString
{
	if (rankedString != aString) {
		[rankedString release];
		rankedString = [aString copy];
	}
}

@end
