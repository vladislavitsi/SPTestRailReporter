//
//  MITestRailSectionTests.m
//  TestRailReporter
//
//  Created by Siddartha Polisetty on 4/3/16.
//  Copyright © 2016 Sid Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MITestRailReporter.h"
#import "MITestRailConfigurationBuilder.h"

@interface MITestRailSectionTests : XCTestCase
@property (nonatomic, strong) NSNumber *createdProjectId;
@property (nonatomic, strong) NSNumber *createdSuiteId;
@end

@implementation MITestRailSectionTests

- (void)setUp {
    [super setUp];
    NSError *error = nil;
    [MITestRailConfigurationBuilder sharedConfigurationBuilder].testRailBaseURL = [NSURL URLWithString:@"https://siddarthapolisetty.testrail.net"];
    [MITestRailConfigurationBuilder sharedConfigurationBuilder].userName = @"siddarthpolishetty@yahoo.com";
    [MITestRailConfigurationBuilder sharedConfigurationBuilder].password = @"Test1234!";
    MITestRailProject *projectForTesting = [[MITestRailProject alloc] initWithName:@"Project Milestone Test" Announcement:@"testing the API" Mode:MITestRailSuiteModeMultipleSuites];
    projectForTesting = [[MITestRailReporter sharedReporter] addProject:projectForTesting Error:&error];
    self.createdProjectId = projectForTesting.projectId;
    MITestRailSuite *suite1 = [[MITestRailSuite alloc] initWithName:@"My New Suite 1" Description:@"Testing" ProjectId:self.createdProjectId];
    suite1 = [[MITestRailReporter sharedReporter] addSuite:suite1 ForProjectId:self.createdProjectId Error:&error];
    self.createdSuiteId = suite1.suiteId;
}

- (void)testSectionsAPI {
    NSError *error = nil;
    //step 1 : add a couple of sections
    for (int i = 0; i < 3; i++ ) {
        MITestRailSection *section = [[MITestRailSection alloc] init];
        section.name = [NSString stringWithFormat:@"Section - %@", [[NSUUID UUID] UUIDString]];
        section.suiteId = self.createdSuiteId;
        section.sectionDescription = @"";
        [[MITestRailReporter sharedReporter] addSection:section ForProjectId:self.createdProjectId Error:&error];
    }
    //step 2 : list all sections for a given project
    NSArray *sections = [[MITestRailReporter sharedReporter] getAllSectionsForProjectWithId:self.createdProjectId WithSuiteId:self.createdSuiteId Error:&error];
    //step 3 : update all sections
    for (MITestRailSection *section in sections) {
        section.name = [NSString stringWithFormat:@"%@ - Updated", section.name];
        [[MITestRailReporter sharedReporter] updateSection:section Error:&error];
    }
    //step 4 : fetch a section by id
    NSNumber *sectionId = [(MITestRailSection *)[sections firstObject] sectionId];
    MITestRailSection *fetchedSection = [[MITestRailReporter sharedReporter] getSectionWithId:sectionId Error:&error];
    //step 5 : delete a particular section
    [[MITestRailReporter sharedReporter] deleteSectionWithId:fetchedSection.sectionId Error:&error];
}

- (void)tearDown {
    NSError *error = nil;
    //step 1 : get all projects
    NSArray *projects = [[MITestRailReporter sharedReporter] getAllProjectsError:&error];
    //step 2 : delete all projects
    for (MITestRailProject *project in projects) {
        [[MITestRailReporter sharedReporter] deleteProjectWithId:project.projectId Error:&error];
    }
}
@end