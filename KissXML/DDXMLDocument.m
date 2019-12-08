#import "DDXMLPrivate.h"
#import "NSString+DDXML.h"
#import <libxml/parser.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * Welcome to KissXML.
 * 
 * The project page has documentation if you have questions.
 * https://github.com/robbiehanson/KissXML
 * 
 * If you're new to the project you may wish to read the "Getting Started" wiki.
 * https://github.com/robbiehanson/KissXML/wiki/GettingStarted
 * 
 * KissXML provides a drop-in replacement for Apple's NSXML class cluster.
 * The goal is to get the exact same behavior as the NSXML classes.
 * 
 * For API Reference, see Apple's excellent documentation,
 * either via Xcode's Mac OS X documentation, or via the web:
 * 
 * https://github.com/robbiehanson/KissXML/wiki/Reference
**/

@implementation DDXMLDocument

/**
 * Returns a DDXML wrapper object for the given primitive node.
 * The given node MUST be non-NULL and of the proper type.
**/
+ (instancetype)nodeWithDocPrimitive:(xmlDocPtr)doc owner:(DDXMLNode *)owner
{
	return [[DDXMLDocument alloc] initWithDocPrimitive:doc owner:owner];
}

- (instancetype)initWithDocPrimitive:(xmlDocPtr)doc owner:(DDXMLNode *)inOwner
{
	self = [super initWithPrimitive:(xmlKindPtr)doc owner:inOwner];
	return self;
}

+ (instancetype)nodeWithPrimitive:(xmlKindPtr)kindPtr owner:(DDXMLNode *)owner
{
	// Promote initializers which use proper parameter types to enable compiler to catch more mistakes
	NSAssert(NO, @"Use nodeWithDocPrimitive:owner:");
	
	return nil;
}

- (instancetype)initWithPrimitive:(xmlKindPtr)kindPtr owner:(DDXMLNode *)inOwner
{
	// Promote initializers which use proper parameter types to enable compiler to catch more mistakes.
	NSAssert(NO, @"Use initWithDocPrimitive:owner:");
	
	return nil;
}

/**
 * Initializes and returns a DDXMLDocument object created from an NSData object.
 * 
 * Returns an initialized DDXMLDocument object, or nil if initialization fails
 * because of parsing errors or other reasons.
**/
- (instancetype)initWithXMLString:(NSString *)string options:(DDNSXMLNodeOptions)mask error:(NSError **)error
{
	return [self initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
	                  options:mask
	                    error:error];
}

/**
 * Initializes and returns a DDXMLDocument object created from an NSData object.
 * 
 * Returns an initialized DDXMLDocument object, or nil if initialization fails
 * because of parsing errors or other reasons.
**/
- (instancetype)initWithData:(NSData *)data options:(DDNSXMLNodeOptions)mask error:(NSError **)error
{
	if (data == nil || [data length] == 0)
	{
		if (error) *error = [NSError errorWithDomain:@"DDXMLErrorDomain" code:0 userInfo:nil];
		
		return nil;
	}
	
	// Even though xmlKeepBlanksDefault(0) is called in DDXMLNode's initialize method,
	// it has been documented that this call seems to get reset on the iPhone:
	// http://code.google.com/p/kissxml/issues/detail?id=8
	// 
	// Therefore, we call it again here just to be safe.
	xmlKeepBlanksDefault(0);
	
	xmlDocPtr doc = xmlParseMemory([data bytes], (int)[data length]);
	if (doc == NULL)
	{
		if (error) *error = [NSError errorWithDomain:@"DDXMLErrorDomain" code:1 userInfo:nil];
		
		return nil;
	}
	
	return [self initWithDocPrimitive:doc owner:nil];
}

- (id)init
{
    xmlDocPtr doc = xmlNewDoc(BAD_CAST "1.0");
    
    return [self initWithDocPrimitive:doc owner:nil];
}

- (instancetype)initWithRootElement:(DDXMLElement *)element
{
#if DDXML_DEBUG_MEMORY_ISSUES
    DDXMLNotZombieAssert();
#endif
    
    xmlDocPtr doc = xmlNewDoc(BAD_CAST "1.0");
    
    self = [self initWithDocPrimitive:doc owner:nil];
    
    [self setRootElement:element];
    
    return self;
}

- (void)setVersion:(NSString *)version
{
    const xmlChar *xmlVersion = [version dd_xmlChar];
    
    xmlDocPtr doc = (xmlDocPtr)self->genericPtr;
    doc->version = xmlStrdup(xmlVersion);
}

- (NSString *)version
{
    xmlDocPtr doc = (xmlDocPtr)self->genericPtr;
    return [NSString stringWithUTF8String:(const char *)doc->version];
}

- (void)setStandalone:(BOOL)standalone
{
    xmlDocPtr doc = (xmlDocPtr)self->genericPtr;
    doc->standalone = standalone ? 1 : 0;
}

- (BOOL)isStandalone
{
    xmlDocPtr doc = (xmlDocPtr)self->genericPtr;
    return doc->standalone != 0;
}

- (void)setDTD:(DDXMLDTD *)DTD
{
    xmlDocPtr doc = (xmlDocPtr)self->genericPtr;
    
    const xmlChar *name = [DTD.name dd_xmlChar];
    const xmlChar *externalID = [DTD.publicID dd_xmlChar];
    const xmlChar *systemID = [DTD.systemID dd_xmlChar];
    
    xmlNewDtd(doc, name, externalID, systemID);
}

- (DDXMLDTD *)DTD
{
    xmlDocPtr doc = (xmlDocPtr)self->genericPtr;
    xmlDtdPtr dtd = (xmlDtdPtr)xmlGetIntSubset(doc);
    
    DDXMLDTD *DTD = [[DDXMLDTD alloc] init];
    DTD.name = [NSString stringWithUTF8String:(const char *)dtd->name];
    DTD.publicID = [NSString stringWithUTF8String:(const char *)dtd->ExternalID];
    DTD.systemID = [NSString stringWithUTF8String:(const char *)dtd->SystemID];
    
    return DTD;
}

- (void)setRootElement:(DDXMLNode *)root
{
#if DDXML_DEBUG_MEMORY_ISSUES
    DDXMLNotZombieAssert();
#endif
    
    // NSXML version uses this same assertion
    DDXMLAssert([root _hasParent] == NO, @"Cannot add an attribute with a parent; detach or copy first");
    DDXMLAssert(IsXmlElementPtr(root->genericPtr), @"Not an attribute");
    
    xmlDocPtr doc = (xmlDocPtr)self->genericPtr;
    
    xmlDocSetRootElement(doc, (xmlNodePtr)root->genericPtr);
    
    // The attribute is now part of the xml tree heirarchy
    root->owner = self;
}

/**
 * Returns the root element of the receiver.
**/
- (DDXMLElement *)rootElement
{
#if DDXML_DEBUG_MEMORY_ISSUES
	DDXMLNotZombieAssert();
#endif
	
	xmlDocPtr doc = (xmlDocPtr)self->genericPtr;
	
	// doc->children is a list containing possibly comments, DTDs, etc...
	
	xmlNodePtr rootNode = xmlDocGetRootElement(doc);
	
	if (rootNode != NULL)
		return [DDXMLElement nodeWithElementPrimitive:rootNode owner:self];
	else
		return nil;
}

- (NSData *)XMLData
{
	// Zombie test occurs in XMLString
	
	return [[self XMLString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)XMLDataWithOptions:(DDNSXMLNodeOptions)options
{
	// Zombie test occurs in XMLString
	
	return [[self XMLStringWithOptions:options] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
