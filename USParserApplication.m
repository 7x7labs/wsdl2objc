
#import "USParserApplication.h"


@implementation USParserApplication
@synthesize fileName;
@synthesize url;

-(id)initWithArgs: (const char **)argv andArgCount: (int) argc
{
	if((self = [super init]))
	{
		[self parseArgs:argv andArgCount:argc];
		namespaceAliases = [NSDictionary dictionary];
	}
	return self;
}

-(void)dealloc
{
	[fileName release];
	[url release];
	[super dealloc];
}

-(BOOL)passesSanityCheck
{
	if([self usingFile] && [self usingURL])
	{
		NSLog(@"Cannot parse a WSDL using both a file and a URL");
		return NO;
	}
	if(![self usingFile] && ![self usingURL])
	{
		NSLog(@"Must parse a WSDL from either a file or a URL");
		return NO;
	}
	
	if([self usingFile] && (!fileName || [fileName length] == 0))
	{
		NSLog(@"You must specify a filename.");
		return NO;
	}
	   
	if([self usingURL] && (!url || [url length] == 0))
	{
		NSLog(@"You must specify a URL.");
		return NO;
	}
				
	return YES;
}

-(void)parseArgs:  (const char **)argv andArgCount: (int) argc
{
	//I usually set a hardcoded file to use to make it easier to just Run the project
	self.fileName = @"/Users/willia4/projects/WSDLParser/wsdl.xml";
	self.url = @"";
	
//	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
//	self.fileName = [args stringForKey:@"f"];
//	self.url = [args stringForKey:@"u"];
}

-(BOOL)usingFile
{
	return (self.fileName && [self.fileName length] > 0);
}

-(BOOL)usingURL
{
	return (self.url && [self.url length] > 0);
}


-(void)magic
{
	NSLog(@"Magic...");
	
	NSXMLDocument *xml = [self getXML];
	
	USParser *parser = [[USParser alloc] initWithWSDL:xml];
	USWSDL *wsdl = [parser parse];
	[self writeDebugInfoForWSDL:wsdl];
	[parser release];
	
	
	
	NSLog(@"Magic done...");
}


-(NSXMLDocument*)getXML
{
	NSXMLDocument *r = nil;
	NSError *err = nil;
	
	if([self usingFile])
	{
		NSString *s = [NSString stringWithContentsOfFile:self.fileName encoding:NSUTF8StringEncoding error:&err];
		if(!s)
		{
			NSLog(@"Could not access file");
			if(err)
			{
				NSLog([err description]);
			}
			return nil;
		}
		r = [[NSXMLDocument alloc] initWithXMLString:s options:0 error:&err];
		if(!r)
		{
			NSLog(@"Could not parse xml");
			if(err)
			{
				NSLog([err description]);
			}
			return nil;
		}
	}
	else if([self usingURL])
	{
		NSURL *u = [NSURL URLWithString:self.url];
		if(!u)
		{
			NSLog(@"Invalid URL");
			return nil;
		}
		
		r = [[[NSXMLDocument alloc] initWithContentsOfURL:u options:0 error:&err] autorelease];
		if(!r)
		{
			NSLog(@"Could not parse xml");
			if(err)
			{
				NSLog([err description]);
			}
			return nil;
		}
	}
	
	return r;
}

-(void)writeDebugInfoForWSDL: (USWSDL*)wsdl
{
	if(!wsdl)
	{
		NSLog(@"No WSDL!!");
		return;
	}
	
	if(NO) //write out schemas
	{
		for(USSchema *schema in wsdl.schemas)
		{
			NSLog(@"Schema: %@", [schema fullName]);
			
			if(YES) //write out types
			{
				for(id<USType> t in [schema types])
				{
					if([t isComplexType])
					{
						USComplexType *ct = (USComplexType*)t;
						NSLog(@"\tComplex type: %@", ct.typeName);
						for(USAttribute *at in ct.attributes)
						{
							if([at.type isSimpleType])
							{
								USSimpleType *st = (USSimpleType*)at.type;
								NSLog(@"\t\tSimple Type attribute: %@, type: %@ representation: %@, default: %@",at.attributeName, st.typeName, st.representationClass, at.attributeDefault);
							}
							else
							{
								USComplexType *act = (USComplexType*)at.type;
								NSString *baseClass = @"No base";
								if(act.superClass)
									baseClass = act.superClass.typeName;
								NSLog(@"\t\tComplex type attribute: %@, type: %@, base: %@, default: %@", at.attributeName, act.typeName, baseClass, at.attributeDefault);
							}
						}
					}
					else
					{
						USSimpleType *st = (USSimpleType*)t;
						NSLog(@"\tSimple type: %@, representation class: %@", st.typeName, st.representationClass);
						if([st.enumerationValues count] > 0)
						{
							NSLog(@"\t\tEnumeration values: ");
							for(NSString *v in st.enumerationValues)
							{
								NSLog(@"\t\t\t%@", v);
							}
						}
					}
				}
			}
		}
		
		if(YES) //write out messages
		{
			for(USMessage *message in wsdl.messages)
			{
				NSLog(@"Message: %@, Part name: %@, Part type: %@", message.messageName, message.partName, [message.partType typeName]);
			}
		}
	}
	
	if(YES) //write potential problems
	{
		for(USSchema *schema in wsdl.schemas)
		{
			if([schema.types count] == 0)
			{
				NSLog(@"POTENTIAL ERROR -- Schema %@ does not contain any types!", schema.fullName);
			}
		}
	}
}
@end
