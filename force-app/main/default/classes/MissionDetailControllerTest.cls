@IsTest
private class MissionDetailControllerTest {
  @testSetup
  static void setup() {
    // create data for tests
    Account account = TestDataService.createAccount('Test Account');
    insert account;

    Contact contact = TestDataService.createContact(
      'Test Contact',
      'test@gmail.com',
      account.Id
    );
    insert contact;

    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Superhero Community User'
    ]
    .Id;
    User communityUser = TestDataService.createCommunityUser(
      contact.Id,
      profileId,
      'Test',
      'SuperheroUser'
    );
    insert communityUser;

    Guild__c guild = TestDataService.createGuild('Test guild');
    insert guild;

    Hero__c hero = TestDataService.createHero(
      'Test hero',
      contact.Id,
      guild.Id
    );
    insert hero;

    Superhero_Mission__c superheroMission = TestDataService.createSuperheroMission(
      'Test subject',
      guild.Id
    );
    insert superheroMission;

    Mission_Assignment__c missionAssignment = TestDataService.createMissionAssignment(
      hero.Id,
      superheroMission.Id
    );
    insert missionAssignment;
  }

  // Test fetching of Hero details
  @IsTest
  static void getHeroDetailsTest() {
    User user = [SELECT Id FROM User WHERE LastName = 'SuperheroUser'];
    System.runAs(user) {
      MissionDetailController.HeroDetailsWrapper heroResult = MissionDetailController.getHeroDetails();
      System.assert(heroResult != null, 'Hero record should be found');
    }
  }

  // Test fetching of Mission details
  @IsTest
  static void getMissionDetailsTest() {
    User user = [SELECT Id FROM User WHERE LastName = 'SuperheroUser'];
    Superhero_Mission__c superheroMission = [
      SELECT Id
      FROM Superhero_Mission__c
      LIMIT 1
    ];

    Hero__c hero = [SELECT Id FROM Hero__c LIMIT 1];

    System.runAs(user) {
      MissionDetailController.MissionDetailsWrapper superheroMissionResult = MissionDetailController.getMissionDetails(
        superheroMission.Id,
        hero.Id
      );
      System.assert(
        superheroMissionResult != null,
        'Superhero Mission should be found by Id'
      );
    }
  }

  // Test if checking of how many Mission Assignments a current user has
  @IsTest
  static void checkHeroMissionAssignmentsTest() {
    User user = [SELECT Id FROM User WHERE LastName = 'SuperheroUser'];
    Hero__c hero = [SELECT Id FROM Hero__c LIMIT 1];
    System.runAs(user) {
      Boolean missionAssignmentsResult = MissionDetailController.checkHeroMissionAssignments(
        hero.Id
      );
      System.assertEquals(
        true,
        missionAssignmentsResult,
        'Should be found less than 3 unfinished Mission Assignments'
      );
    }
  }

  // Test creating of Mission Assignment
  @IsTest
  static void createMissionAssignmentTest() {
    Hero__c hero = [SELECT Id FROM Hero__c LIMIT 1];
    Superhero_Mission__c mission = [
      SELECT Id
      FROM Superhero_Mission__c
      LIMIT 1
    ];

    Id newSuperheroMissionId = MissionDetailController.createMissionAssignment(
      hero.Id,
      mission.Id
    );
    System.assert(
      newSuperheroMissionId != null,
      'New Superhero Mission should be created'
    );
  }

  // Test updating of Mission Assignment
  @IsTest
  static void updateMissionAssignmentTest() {
    User user = [SELECT Id FROM User WHERE LastName = 'SuperheroUser'];
    Hero__c hero = [SELECT Id FROM Hero__c LIMIT 1];
    Superhero_Mission__c mission = [
      SELECT Id
      FROM Superhero_Mission__c
      LIMIT 1
    ];
    Mission_Assignment__c missionAssignment = [
      SELECT Id, Status__c, Mission__c, Hero__c
      FROM Mission_Assignment__c
      LIMIT 1
    ];
    Id updatedMissionAssignmentId = null;
    missionAssignment.OwnerId = user.Id;
    update missionAssignment;
    System.runAs(user) {
      updatedMissionAssignmentId = MissionDetailController.updateMissionAssignment(
        missionAssignment.Hero__c,
        missionAssignment.Mission__c
      );
    }
    Mission_Assignment__c updatedMissionAssignment = [
      SELECT Id, Status__c
      FROM Mission_Assignment__c
      WHERE Id = :updatedMissionAssignmentId
      LIMIT 1
    ];

    System.assertNotEquals(
      missionAssignment.Status__c,
      updatedMissionAssignment.Status__c,
      'Status of the Mission Assignment should be updated'
    );
  }

  @IsTest
  static void GetAllPossibleRanksTest() {
    // Call the AuraEnabled method
    List<String> result = MissionDetailController.getAllPossibleRanks();

    // Assert that the method returns the expected values
    List<String> expectedRanks = new List<String>();

    expectedRanks.add('S');
    expectedRanks.add('A');
    expectedRanks.add('B');
    expectedRanks.add('C');
    expectedRanks.add('D'); // Add all possible rank values to this list

    System.assertEquals(
      expectedRanks,
      result,
      'Method should return all possible ranks'
    );
  }
}
