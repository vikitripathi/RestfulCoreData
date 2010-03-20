//
//  PTTrackerRemoteModel.m
//  Tracker
//
//  Created by Luke Redpath on 18/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTObject.h"
#import "PTManagedObject.h"

@implementation PTObject

@synthesize remoteId;
@synthesize managedObject;
@synthesize entityName;

+ (void)initialize {
  [self setDelegate:self];
  [self setBaseURL:[NSURL URLWithString:@"http://localhost:3000/"]];
  [self setFormat:HRDataFormatXML];
}

+ (NSString *)entityName;
{
  return nil;
}

- (void)dealloc;
{
  [entityName release];
  [super dealloc];
}

- (id)init;
{
  if (self = [super init]) {
    entityName = [[self class] entityName];
  }
  return self;
}

- (PTManagedObject *)newManagedObjectInContext:(NSManagedObjectContext *)context;
{
  NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
  PTManagedObject *object = [[PTManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
  object.remoteObject = (id<PTRemoteObject>)self;
  return object;
}

- (void)initializeInManagedObjectContext:(NSManagedObjectContext *)context;
{
  PTManagedObject *newManagedObject = [self newManagedObjectInContext:context];
  [self setManagedObject:newManagedObject isMaster:NO];
  [newManagedObject release];
}

- (id)initWithManagedObject:(PTManagedObject *)object;
{
  if (self = [super init]) {
    [self setManagedObject:object isMaster:YES];
  }
  return self;
}

- (void)setManagedObject:(PTManagedObject *)object;
{
  if (object != managedObject) {
    [managedObject release];
    managedObject = [object retain];
    managedObject.remoteObject = (id<PTRemoteObject>)self;
  }
}

#pragma mark -
#pragma mark PTManagedObject synching

- (void)setManagedObject:(PTManagedObject *)object isMaster:(BOOL)isMaster;
{
  self.managedObject = object;
  
  if (isMaster) {
    [self syncSelfToManagedObject:object];
  } else {
    [self syncManagedObjectToSelf:object];
  }
}

- (void)syncManagedObject;
{
  if (self.managedObject) {
    [self syncManagedObjectToSelf:self.managedObject];
  }
}

- (void)syncManagedObjectToSelf:(PTManagedObject *)object;
{
  [object setValue:self.remoteId forKey:@"remoteId"];
}

- (void)syncSelfToManagedObject:(PTManagedObject *)object;
{
  self.remoteId = [object valueForKey:@"remoteId"];
}

#pragma mark -
#pragma mark Default HRRestConnection delegate methods

+ (void)restConnection:(NSURLConnection *)connection didFailWithError:(NSError *)error object:(id)object 
{
  NSLog(@"Connection error %@", error);
}

+ (void)restConnection:(NSURLConnection *)connection didReceiveError:(NSError *)error 
              response:(NSHTTPURLResponse *)response object:(id)object 
{
  NSLog(@"Response error %@, %@", response, error);
  if (response) {
    NSLog(@"Response code %d", [response statusCode]);
  }
}

+ (void)restConnection:(NSURLConnection *)connection didReceiveParseError:(NSError *)error 
          responseBody:(NSString *)string 
{
  NSLog(@"Parse error %@", error);
}

@end