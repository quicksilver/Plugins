
#include <CoreFoundation/CoreFoundation.h>
#include <XARuntime.h>
#include <XAJob.h>

void printUsage(void)
{
	fprintf(stdout, "usage: xattr <operation [options]> <files>\n");
	fprintf(stdout, "       operations: --set --set-data --copy --delete --list --list-parseable\n\n");
	fprintf(stdout, "            --set: [-s]  key value\n");
	fprintf(stdout, "                   specify a key/value attribute pair\n\n");
	fprintf(stdout, "       --set-data: [-sd] key path\n");
	fprintf(stdout, "                   specify a key/value attribute pair\n");
	fprintf(stdout, "                   the value is the data located at \"path\"\n");
	fprintf(stdout, "                   the data has a maximum allowable size of 4K\n\n");
	fprintf(stdout, "           --copy: [-c]  key path\n");
	fprintf(stdout, "                   copy a key/value attribute pair from \"path\"\n\n");
	fprintf(stdout, "         --delete: [-d -rm] key\n");
	fprintf(stdout, "                   delete a key/value attribute pair\n\n");
	fprintf(stdout, "           --list: [-l]  list all key/value attribute pairs\n\n");
	fprintf(stdout, " --list-parseable: [-lp] list all key/value attribute pairs in a parseable format\n\n");
	fprintf(stdout, "            --get: [-g]  print key/value pair\n\n");
	fprintf(stdout, "  --get-parseable: [-gp] print key/value pair in a parseable format\n\n");
}

int main(int argc, char **argv)
{
	XAJobRef jobRef = 0x00;
	
	_XAInitializeRuntime();

	jobRef = XAJobCreateWithArguments(kCFAllocatorDefault, argc, argv);

	if(jobRef)
	{
		XAJobExecute(jobRef);
		
		CFRelease(jobRef);
	}else
	{
		printUsage();
	}

	return(0x00);
}

