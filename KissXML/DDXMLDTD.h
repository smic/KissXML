#import <Foundation/Foundation.h>
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


NS_ASSUME_NONNULL_BEGIN

@interface DDXMLDTD : DDXMLNode

@property(copy) NSString *publicID;

@property(copy) NSString *systemID;

@end

NS_ASSUME_NONNULL_END
