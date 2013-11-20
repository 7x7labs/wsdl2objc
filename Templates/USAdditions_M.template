//
//    USAdditions.m
//    WSDLParser
//
//    Created by John Ogle on 9/5/08.
//    Copyright 2008 LightSPEED Technologies. All rights reserved.
//    Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
//    Modifications copyright (c) 2009 Micropraxis Ltd.
//    Modified by Henri Asseily on 2009-09-04 for SOAP 1.2 faults
//
//
//    NSData (MBBase64) category taken from "MiloBird" at http://www.cocoadev.com/index.pl?BaseSixtyFour
//

#import "USAdditions.h"

#import "NSDate+ISO8601Parsing.h"
#import "NSDate+ISO8601Unparsing.h"

#import <libxml/parser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#import <libxml/c14n.h>

@implementation NSString(USAdditions)
- (NSString *)stringByEscapingXML {
    NSMutableString *escapedString = [self mutableCopy];

    [escapedString replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:0 range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"'"  withString:@"&apos;" options:0 range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:0 range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:0 range:NSMakeRange(0, [escapedString length])];

    return escapedString;
}

- (NSString *)stringByUnescapingXML {
    NSMutableString *unescapedString = [self mutableCopy];

    [unescapedString replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&apos;" withString:@"'"  options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&lt;"   withString:@"<"  options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&gt;"   withString:@">"  options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&amp;"  withString:@"&"  options:0 range:NSMakeRange(0, [unescapedString length])];

    return unescapedString;
}

- (const xmlChar *)xmlString {
    return (const xmlChar *)[[self stringByEscapingXML] UTF8String];
}

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix {
    NSString *nodeName = elName;

    if ([elNSPrefix length])
        nodeName = [NSString stringWithFormat:@"%@:%@", elNSPrefix, elName];

    return xmlNewDocNode(doc, NULL, [nodeName xmlString], [self xmlString]);
}

+ (NSString *)deserializeNode:(xmlNodePtr)cur {
    xmlChar *elementText = xmlNodeListGetString(cur->doc, cur->children, 1);
    if (elementText)
        return [[NSString stringWithXmlString:elementText free:YES] stringByUnescapingXML];
    return @"";
}

+ (NSString *)stringWithXmlString:(xmlChar *)str free:(BOOL)freeOriginal {
    if (!str) return nil;
    NSString *string = [NSString stringWithCString:(char*)str encoding:NSUTF8StringEncoding];
    if (freeOriginal)
        xmlFree(str);
    return string;
}
@end

@implementation NSNumber(USAdditions)
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix {
    return [[self stringValue] xmlNodeForDoc:doc elementName:elName elementNSPrefix:elNSPrefix];
}

+ (NSNumber *)deserializeNode:(xmlNodePtr)cur {
    return @([[NSString deserializeNode:cur] doubleValue]);
}
@end

@implementation NSDecimalNumber (USAdditions)
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix {
    return [[self stringValue] xmlNodeForDoc:doc elementName:elName elementNSPrefix:elNSPrefix];
}

+ (NSDecimalNumber *)deserializeNode:(xmlNodePtr)cur {
    return [NSDecimalNumber decimalNumberWithString:[NSString deserializeNode:cur]];
}
@end

@implementation NSDate (USAdditions)
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix {
    return [[self ISO8601DateString] xmlNodeForDoc:doc elementName:elName elementNSPrefix:elNSPrefix];
}

+ (NSDate *)deserializeNode:(xmlNodePtr)cur {
    return [NSDate dateWithISO8601String:[NSString deserializeNode:cur]];
}
@end

@implementation NSData(USAdditions)
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix {
    return [[self base64Encoding] xmlNodeForDoc:doc elementName:elName elementNSPrefix:elNSPrefix];
}

+ (NSData *)deserializeNode:(xmlNodePtr)cur {
    if (cur) {
		xmlChar *elementText = xmlNodeListGetString(cur->doc, cur->children, 1);
        NSData *data = [NSData data];
        if (elementText)
            data = [NSData dataWithBase64EncodedString:(const char *)elementText];
        xmlFree(elementText);
        return data;
    }
    return nil;
}
@end

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData(MBBase64)

+ (id)dataWithBase64EncodedString:(const char *)string {
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:@"Error: String must not be nil"];

    if (*string == 0)
        return [NSData data];

    static char decodingTable[256] = "";
    if (!decodingTable[0]) {
        memset(decodingTable, CHAR_MAX, 256);
        for (NSUInteger i = 0; i < 64; i++)
            decodingTable[encodingTable[i]] = i;
    }

    char *bytes = malloc(((strlen(string) + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;

    NSUInteger length = 0;
    NSUInteger i = 0;

    while (YES) {
        char buffer[4];
        NSUInteger bufferLength;

        for (bufferLength = 0; bufferLength < 4; i++) {
            if (string[i] == '\0')
                break;
            if (isspace(string[i]) || string[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[string[i]];
            if (buffer[bufferLength++] == CHAR_MAX) { //  Illegal character!
                free(bytes);
                return nil;
            }
        }

        if (bufferLength == 0)
            break;
        if (bufferLength == 1) { //  At least two characters are needed to produce one byte!
            free(bytes);
            return nil;
        }

        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }

    return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64Encoding; {
    if ([self length] == 0)
        return @"";

    char *characters = malloc((([self length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;

    NSUInteger    length = 0;
    NSUInteger    i = 0;

    while (i < [self length]) {
        char buffer[3] = {0, 0, 0};
        int bufferLength = 0;

        while (bufferLength < 3 && i < [self length])
            buffer[bufferLength++] = ((char *)[self bytes])[i++];

        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else
            characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else
            characters[length++] = '=';
    }

    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

@end

@implementation NSArray (USAdditions)
- (void)addToNode:(xmlNodePtr)node elementName:(NSString *)name elementNSPrefix:(NSString *)nsPrefix {
    for (id child in self) {
        xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:name elementNSPrefix:nsPrefix]);
    }
}
@end

@implementation SOAPFault
+ (id)deserializeFaultDetails:(xmlNodePtr)cur expectedExceptions:(NSDictionary *)exceptions {
    if (cur->children) {
        cur = cur->children;
        if (cur && cur->type == XML_ELEMENT_NODE) {
            // check if any expected exception is in details
            for (NSString *eName in [exceptions allKeys]) {
                if (xmlStrEqual(cur->name, (const xmlChar *) [eName cStringUsingEncoding:NSASCIIStringEncoding])) {
                    // expect only one exception
                    return [NSClassFromString([exceptions objectForKey:eName]) deserializeNode:cur];
                }
            }
        }

        cur = cur->parent;
    }

    // the old NSString fallback
    return [NSString deserializeNode:cur];
}

+ (SOAPFault *)deserializeNode:(xmlNodePtr)cur expectedExceptions:(NSDictionary *)exceptions {
    SOAPFault *soapFault = [SOAPFault new];
    NSString *ns = [NSString stringWithXmlString:(xmlChar *)cur->ns->href free:NO];
    if (!ns) return soapFault;
    if ([ns isEqualToString:@"http://schemas.xmlsoap.org/soap/envelope/"]) {
        // soap 1.1
        for (cur = cur->children; cur != NULL; cur = cur->next) {
            if (cur->type == XML_ELEMENT_NODE) {
                if (xmlStrEqual(cur->name, (const xmlChar *) "faultcode"))
                    soapFault.faultcode = [NSString deserializeNode:cur];
                else if (xmlStrEqual(cur->name, (const xmlChar *) "faultstring"))
                    soapFault.faultstring = [NSString deserializeNode:cur];
                else if (xmlStrEqual(cur->name, (const xmlChar *) "faultactor"))
                    soapFault.faultactor = [NSString deserializeNode:cur];
                else if (xmlStrEqual(cur->name, (const xmlChar *) "detail"))
                    soapFault.detail = [SOAPFault deserializeFaultDetails:cur expectedExceptions:exceptions];
            }
        }
    }
    else if ([ns isEqualToString:@"http://www.w3.org/2003/05/soap-envelope"]) {
        // soap 1.2
        for (cur = cur->children; cur != NULL; cur = cur->next) {
            if (cur->type == XML_ELEMENT_NODE) {
                if (xmlStrEqual(cur->name, (const xmlChar *) "Code")) {
                    for (xmlNodePtr newcur = cur->children; newcur != NULL; newcur = newcur->next) {
                        if (xmlStrEqual(newcur->name, (const xmlChar *)"Value")) {
                            soapFault.faultcode = [NSString deserializeNode:newcur];
                            break;
                        }
                    }
                    // TODO: Add Subcode handling
                }
                if (xmlStrEqual(cur->name, (const xmlChar *)"Reason")) {
                    xmlChar *theReason = xmlNodeGetContent(cur);
                    if (theReason)
                        soapFault.faultstring = [NSString stringWithXmlString:theReason free:YES];
                }
                else if (xmlStrEqual(cur->name, (const xmlChar *)"Node"))
                    soapFault.faultactor = [NSString deserializeNode:cur];
                else if (xmlStrEqual(cur->name, (const xmlChar *) "Detail"))
                    soapFault.detail = [SOAPFault deserializeFaultDetails:cur expectedExceptions:exceptions];
                // TODO: Add "Role" ivar
            }
        }
    }

    return soapFault;
}

- (NSString *)simpleFaultString {
    NSString *simpleString = [self.faultstring stringByReplacingOccurrencesOfString:@"System.Web.Services.Protocols.SoapException: " withString: @""];

    NSRange suffixRange = [simpleString rangeOfString: @"\n   at "];
    if (suffixRange.length > 0)
        return [simpleString substringToIndex:suffixRange.location];

    return simpleString;
}

@end

@implementation SOAPSigner
- (id) initWithDelegate:(id<SOAPSignerDelegate>)del {
    self = [super init];
    self.delegate = del;
    return self;
}

static int register_namespaces(xmlXPathContextPtr xpathCtx, const xmlChar* nsList) {
    if (!xpathCtx || !nsList)
        return -1;

    xmlChar *nsListDup = xmlStrdup(nsList);
    if (!nsListDup) return -1;

    for (xmlChar *next = nsListDup; next; ) {
        /* skip spaces */
        while ((*next) == ' ') next++;
        if ((*next) == '\0') break;

        /* find prefix */
        xmlChar *prefix = next;
        next = (xmlChar*)xmlStrchr(next, '=');
        if (next == NULL) {
            xmlFree(nsListDup);
            return -1;
        }
        *(next++) = '\0';

        /* find href */
        xmlChar *href = next;
        next = (xmlChar*)xmlStrchr(next, ' ');
        if (next != NULL) {
            *(next++) = '\0';
        }

        /* do register namespace */
        if (xmlXPathRegisterNs(xpathCtx, prefix, href) != 0) {
            xmlFree(nsListDup);
            return -1;
        }
    }

    xmlFree(nsListDup);
    return 0;
}

static xmlXPathObjectPtr execute_xpath_expression(xmlDocPtr doc, const xmlChar* xpathExpr, const xmlChar* nsList) {
    if (!doc || !xpathExpr) return NULL;

    /* Create xpath evaluation context */
    xmlXPathContextPtr xpathCtx = xmlXPathNewContext(doc);
    if (xpathCtx == NULL) return NULL;

    /* Register namespaces from list (if any) */
    if ((nsList != NULL) && (register_namespaces(xpathCtx, nsList) < 0)) {
        xmlXPathFreeContext(xpathCtx);
        return NULL;
    }

    /* Evaluate xpath expression */
    xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression(xpathExpr, xpathCtx);
    xmlXPathFreeContext(xpathCtx);

    return xpathObj;
}

- (xmlNodePtr)securityHeaderTemplate {
    xmlNodePtr securityRoot = xmlNewNode(NULL, (const xmlChar*)"Security");
    xmlNsPtr wsse = xmlNewNs(securityRoot, (const xmlChar*)"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd", (const xmlChar*)"wsse");
    xmlSetNs(securityRoot, wsse);

    xmlNodePtr n0 = securityRoot;
    xmlNodePtr n1 = xmlNewNode(NULL, (const xmlChar*)"Signature");
    xmlNsPtr ds = xmlNewNs(securityRoot, (const xmlChar*)"http://www.w3.org/2000/09/xmldsig#", (const xmlChar*)"ds");
    xmlSetNs(n1, ds);
    xmlAddChild(n0, n1);

    n0 = n1;
    n1 = xmlNewNode(ds, (const xmlChar*)"SignedInfo");
    xmlAddChild(n0, n1);

    n0 = n1;
    n1 = xmlNewNode(ds, (const xmlChar*)"SignatureValue");
    xmlAddNextSibling(n0, n1);

    n1 = xmlNewNode(ds, (const xmlChar*)"CanonicalizationMethod");
    xmlNewProp(n1, (const xmlChar*)"Algorithm", (const xmlChar*)"http://www.w3.org/2001/10/xml-exc-c14n#");
    xmlAddChild(n0, n1);

    n1 = xmlNewNode(ds, (const xmlChar*)"SignatureMethod");
    xmlNewProp(n1, (const xmlChar*)"Algorithm", (const xmlChar*)"http://www.w3.org/2000/09/xmldsig#rsa-sha1");
    xmlAddChild(n0, n1);

    n1 = xmlNewNode(ds, (const xmlChar*)"Reference");
    xmlNewProp(n1, (const xmlChar*)"URI", (const xmlChar*)"");
    xmlAddChild(n0, n1);

    n0 = n1;
    n1 = xmlNewNode(ds, (const xmlChar*)"Transforms");
    xmlAddChild(n0, n1);

    n0 = n1;
    n1 = xmlNewNode(ds, (const xmlChar*)"DigestMethod");
    xmlNewProp(n1, (const xmlChar*)"Algorithm", (const xmlChar*)"http://www.w3.org/2000/09/xmldsig#sha1");
    xmlAddSibling(n0, n1);

    n1 = xmlNewNode(ds, (const xmlChar*)"DigestValue");
    xmlAddSibling(n0, n1);

    n1 = xmlNewNode(ds, (const xmlChar*)"Transform");
    xmlNewProp(n1, (const xmlChar*)"Algorithm", (const xmlChar*)"http://www.w3.org/2002/06/xmldsig-filter2");
    xmlAddChild(n0, n1);

    n0 = n1;
    n1 = xmlNewNode(NULL, (const xmlChar*)"XPath");
    ds = xmlNewNs(n1, (const xmlChar*)"http://www.w3.org/2002/06/xmldsig-filter2", (const xmlChar*)"ds");
    xmlNewNs(n1, (const xmlChar*)"http://schemas.xmlsoap.org/soap/envelope/", (const xmlChar*)"soap");
    xmlNewProp(n1, (const xmlChar*)"Filter", (const xmlChar*)"intersect");
    xmlNodeSetContent(n1, [@"/soap:Envelope/soap:Body/*" xmlString]);
    xmlSetNs(n1, ds);
    xmlAddChild(n0, n1);

    n1 = xmlNewNode(ds, (const xmlChar*)"Transform");
    xmlNewProp(n1, (const xmlChar*)"Algorithm", (const xmlChar*)"http://www.w3.org/2001/10/xml-exc-c14n#");
    xmlAddSibling(n0, n1);


    return securityRoot;
}

- (NSString *)signRequest:(NSString *)req
{
    // TODO: handle errors

    // convert request back to xmlDoc
    NSData *reqData = [req dataUsingEncoding:NSUTF8StringEncoding];
    xmlDocPtr doc = xmlReadMemory([reqData bytes],
                                  (int)[reqData length],
                                  NULL,
                                  NULL,
                                  XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);

    // find the SOAP Header
    xmlXPathObjectPtr xpathObj = execute_xpath_expression(doc,
                                                          (const xmlChar *)"/soap:Envelope/soap:Header",
                                                          (const xmlChar *)"soap=http://schemas.xmlsoap.org/soap/envelope/");

    xmlNodePtr headerPtr = (xpathObj && xpathObj->nodesetval && xpathObj->nodesetval->nodeTab)
    ? xpathObj->nodesetval->nodeTab[0]
    : NULL;

    // if not present create it
    if (!headerPtr) {
        xmlNsPtr *nss = xmlGetNsList(doc, doc->children);
        xmlNsPtr soap = NULL;
        for (int i = 0; nss && nss[i]; i++) {
            if (xmlStrcmp(nss[i]->href, (const xmlChar *)"http://schemas.xmlsoap.org/soap/envelope/") == 0) {
                soap = nss[i];
                break;
            }
        }

        headerPtr = xmlNewDocNode(doc, soap, (const xmlChar *)"Header", NULL);
        xmlAddPrevSibling(doc->children->children, headerPtr); // the envelope and the body should be there
    }

    // add the security template in the header
    xmlAddChild(headerPtr, [self securityHeaderTemplate]);
    xmlXPathFreeObject(xpathObj);

    // find the referenced content (the XPath expression in the template + all children)
    xpathObj = execute_xpath_expression(doc,
                                        (const xmlChar *)"/soap:Envelope/soap:Body//node() "
                                        "| /soap:Envelope/soap:Body//node()/namespace::* "
                                        "| /soap:Envelope/soap:Body//node()/attribute::*",
                                        (const xmlChar *)"soap=http://schemas.xmlsoap.org/soap/envelope/");

    xmlChar *canonicalized;
    NSUInteger size = (NSUInteger)xmlC14NDocDumpMemory(doc, xpathObj->nodesetval, 1, NULL, 1, &canonicalized);

    // calculate and add its digest value
    NSString *digestValue = [self.delegate base64Encode:[self.delegate digestData:[NSData dataWithBytes:canonicalized length:size]]];
    xmlFree(canonicalized);
    xmlXPathFreeObject(xpathObj);

    xpathObj = execute_xpath_expression(doc,
                                        (const xmlChar *)"/soap:Envelope/soap:Header/wsse:Security/ds:Signature/ds:SignedInfo/ds:Reference/ds:DigestValue",
                                        (const xmlChar *)"soap=http://schemas.xmlsoap.org/soap/envelope/ "
                                        "wsse=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd "
                                        "ds=http://www.w3.org/2000/09/xmldsig#");

    xmlNodePtr dvPtr = xpathObj->nodesetval->nodeTab[0];
    xmlNodeSetContent(dvPtr, [digestValue xmlString]);
    xmlXPathFreeObject(xpathObj);

    // sign the SignedInfo
    xpathObj = execute_xpath_expression(doc,
                                        (const xmlChar *)"/soap:Envelope/soap:Header/wsse:Security/ds:Signature/ds:SignedInfo/descendant-or-self::node() "
                                        "| /soap:Envelope/soap:Header/wsse:Security/ds:Signature/ds:SignedInfo/descendant-or-self::node()/namespace::* "
                                        "| /soap:Envelope/soap:Header/wsse:Security/ds:Signature/ds:SignedInfo/descendant-or-self::node()/attribute::*",
                                        (const xmlChar *)"soap=http://schemas.xmlsoap.org/soap/envelope/ "
                                        "wsse=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd "
                                        "ds=http://www.w3.org/2000/09/xmldsig#");

    size = (NSUInteger)xmlC14NDocDumpMemory(doc, xpathObj->nodesetval, 1, NULL, 1, &canonicalized);

    NSData *signedData = [self.delegate signData:[NSData dataWithBytes:canonicalized length:size]];
    xmlFree(canonicalized);
    xmlXPathFreeObject(xpathObj);

    // if the signing fails ( any reason return NULL so that the request is not sent at all
    if (!signedData) {
        xmlFreeDoc(doc);
        return nil;
    }

    NSString *signatureValue = [self.delegate base64Encode:signedData];
    xpathObj = execute_xpath_expression(doc,
                                        (const xmlChar *)"/soap:Envelope/soap:Header/wsse:Security/ds:Signature/ds:SignatureValue",
                                        (const xmlChar *)"soap=http://schemas.xmlsoap.org/soap/envelope/ "
                                        "wsse=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd "
                                        "ds=http://www.w3.org/2000/09/xmldsig#");

    xmlNodePtr svPtr = xpathObj->nodesetval->nodeTab[0];
    xmlNodeSetContent(svPtr, [signatureValue xmlString]);
    xmlXPathFreeObject(xpathObj);

    xmlC14NDocDumpMemory(doc, NULL, 1, NULL, 1, &canonicalized);
    NSString *serializedForm = [NSString stringWithXmlString:canonicalized free:YES];

    xmlFreeDoc(doc);

    return serializedForm;
}
@end

@interface BasicSSLCredentialsManager ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation BasicSSLCredentialsManager
+ (id)managerWithUsername:(NSString *)usr andPassword:(NSString *)pwd {
    return [[self alloc] initWithUsername:usr andPassword:pwd];
}

- (id)initWithUsername:(NSString *)usr andPassword:(NSString *)pwd {
    self = [super init];
    self.username = usr;
    self.password = pwd;
    return self;
}

- (BOOL)canAuthenticateForAuthenticationMethod:(NSString *)authMethod {
    return [authMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic];
}

- (BOOL)authenticateForChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] > 0)
        return NO;

    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];

    if (![protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
        [NSException raise:@"Authentication method not supported"
                    format:@"%@ not supported.", [protectionSpace authenticationMethod]];

    NSURLCredential *newCredential = [NSURLCredential
                                      credentialWithUser:self.username
                                      password:self.password
                                      persistence:NSURLCredentialPersistenceForSession];
    
    [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    
    return YES;
}
@end
