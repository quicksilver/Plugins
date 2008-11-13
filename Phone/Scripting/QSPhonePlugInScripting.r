#include <Carbon/Carbon.r>

#define Reserved8   reserved, reserved, reserved, reserved, reserved, reserved, reserved, reserved
#define Reserved12  Reserved8, reserved, reserved, reserved, reserved
#define Reserved13  Reserved12, reserved
#define dp_none__   noParams, "", directParamOptional, singleItem, notEnumerated, Reserved13
#define reply_none__   noReply, "", replyOptional, singleItem, notEnumerated, Reserved13
#define synonym_verb__ reply_none__, dp_none__, { }
#define plural__    "", {"", kAESpecialClassProperties, cType, "", reserved, singleItem, notEnumerated, readOnly, Reserved8, noApostrophe, notFeminine, notMasculine, plural}, {}

resource 'aete' (0, "QSPhonePlugIn") {
	0x1,  // major version
	0x0,  // minor version
	english,
	roman,
	{
		"Phone Plug-in",
		"additional commands provided by the Phone Plug-in.",
		'DAEp',
		1,
		1,
		{
			/* Events */

			"dial number",
			"Dial a phone number",
			'DAED', 'Dial',
			reply_none__,
			'TEXT',
			"the number to dial",
			directParamRequired,
			singleItem, notEnumerated, Reserved13,
			{
				"method", 'meth', 'TEXT',
				"dial method",
				optional,
				singleItem, notEnumerated, Reserved13
			}
		},
		{
			/* Classes */

		},
		{
			/* Comparisons */
		},
		{
			/* Enumerations */
		}
	}
};
