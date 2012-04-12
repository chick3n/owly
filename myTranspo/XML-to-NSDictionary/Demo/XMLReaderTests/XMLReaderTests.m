//
//  XMLReaderTests.m
//  XMLReaderTests
//
//  Created by David Perry on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLReaderTests.h"
#import "XMLReader.h"

@implementation XMLReaderTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testXMLReaderFailsWithNoData
{
    NSData *data = nil;
    NSError *error = nil;
    
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    STAssertNil(dictionary, @"dictionary should be nil");
    STAssertNotNil(error, @"error should not be nil");    
}

- (void)testXMLReaderFailsWithNoString
{
    NSString *string = nil;
    NSError *error = nil;
    
    NSDictionary *dictionary = [XMLReader dictionaryForXMLString:string error:&error];
    
    STAssertNil(dictionary, @"dictionary should be nil");
    STAssertNotNil(error, @"error should not be nil");    
}

- (void)testXMLReaderFailsWithInvalidPath
{
    NSString *path = nil;
    NSError *error = nil;
    
    NSDictionary *dictionary = [XMLReader dictionaryForPath:path error:&error];
    
    STAssertNil(dictionary, @"dictionary should be nil");
    STAssertNotNil(error, @"error should not be nil");    
}

- (void)testXMLReaderFailsWithInvalidXML
{
    NSString *xmlString = @"<goodxml>this is good</goodxml><badxml>this is bad</goodxml>";
    NSError *error = nil;
    
    NSDictionary *dictionary = [XMLReader dictionaryForXMLString:xmlString error:&error];
    
    STAssertNil(dictionary, @"dictionary should be nil");
    STAssertNotNil(error, @"error should not be nil");
}

- (void)testXMLReaderSucceedsWithBasicXML
{
    NSString *xmlString = @"<outernode><innernode>somevalue</innernode></outernode>";
    NSError *error = nil;
    
    NSDictionary *dictionary = [XMLReader dictionaryForXMLString:xmlString error:&error];
    
    STAssertNotNil(dictionary, @"dictionary should not be nil");
    STAssertNil(error, @"error should be nil");
    STAssertTrue([[dictionary objectForKey:@"outernode"] isKindOfClass:[NSDictionary class]], @"outernode should be a dictionary");
    STAssertTrue([[[dictionary objectForKey:@"outernode"] objectForKey:@"innernode"] isEqualToString:@"somevalue"], @"node values should match");
}

- (void)testXMLReaderSucceedsWithComplexXML
{
    NSData *xmlData = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"complex" ofType:@"xml"]];
    STAssertNotNil(xmlData, @"Failed to load XML file");
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:xmlData error:&error];
    NSLog(@"%@", [dictionary description]);
    
    STAssertNotNil(dictionary, @"dictionary should not be nil");
    STAssertNil(error, @"error should be nil");
    
    // TODO: Spot check a few of the nodes are correct in the dictionary
}


@end
