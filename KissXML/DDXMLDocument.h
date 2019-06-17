#import <Foundation/Foundation.h>
#import "DDXMLDTD.h"
#import "DDXMLElement.h"
#import "DDXMLNode.h"

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

enum {
	DDXMLDocumentXMLKind NS_SWIFT_NAME(XMLDocumentXMLKind) = 0,
	DDXMLDocumentXHTMLKind NS_SWIFT_NAME(XMLDocumentXHTMLKind),
	DDXMLDocumentHTMLKind NS_SWIFT_NAME(XMLDocumentHTMLKind),
	DDXMLDocumentTextKind NS_SWIFT_NAME(XMLDocumentTextKind)
};
typedef NSUInteger DDXMLDocumentContentKind NS_SWIFT_NAME(XMLDocumentContentKind);

NS_ASSUME_NONNULL_BEGIN
@interface DDXMLDocument : DDXMLNode
{
}

- (nullable instancetype)initWithXMLString:(NSString *)string options:(DDNSXMLNodeOptions)mask error:(NSError **)error;
//- (instancetype)initWithContentsOfURL:(NSURL *)url options:(NSUInteger)mask error:(NSError **)error;
- (nullable instancetype)initWithData:(NSData *)data options:(DDNSXMLNodeOptions)mask error:(NSError **)error;
- (instancetype)initWithRootElement:(DDXMLElement *)element;

//+ (Class)replacementClassForClass:(Class)cls;

@property (nullable, copy) NSString *characterEncoding; //primitive

@property (nullable, copy) NSString *version; //primitive

@property (getter=isStandalone) BOOL standalone; //primitive

//- (void)setDocumentContentKind:(DDXMLDocumentContentKind)kind;
//- (DDXMLDocumentContentKind)documentContentKind;

//- (void)setMIMEType:(NSString *)MIMEType;
//- (NSString *)MIMEType;

@property (nullable, copy) DDXMLDTD *DTD; //primitive

- (void)setRootElement:(DDXMLNode *)root;
- (nullable DDXMLElement *)rootElement;

//- (void)insertChild:(DDXMLNode *)child atIndex:(NSUInteger)index;

//- (void)insertChildren:(NSArray *)children atIndex:(NSUInteger)index;

//- (void)removeChildAtIndex:(NSUInteger)index;

//- (void)setChildren:(NSArray *)children;

//- (void)addChild:(DDXMLNode *)child;

//- (void)replaceChildAtIndex:(NSUInteger)index withNode:(DDXMLNode *)node;

@property (readonly, copy) NSData *XMLData;
- (NSData *)XMLDataWithOptions:(DDNSXMLNodeOptions)options;

//- (instancetype)objectByApplyingXSLT:(NSData *)xslt arguments:(NSDictionary *)arguments error:(NSError **)error;
//- (instancetype)objectByApplyingXSLTString:(NSString *)xslt arguments:(NSDictionary *)arguments error:(NSError **)error;
//- (instancetype)objectByApplyingXSLTAtURL:(NSURL *)xsltURL arguments:(NSDictionary *)argument error:(NSError **)error;

//- (BOOL)validateAndReturnError:(NSError **)error;

@end
#if TARGET_OS_IPHONE || TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
@compatibility_alias XMLDocument DDXMLDocument;
#endif
NS_ASSUME_NONNULL_END
