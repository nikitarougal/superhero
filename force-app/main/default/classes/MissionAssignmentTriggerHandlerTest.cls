@IsTest
private class MissionAssignmentTriggerHandlerTest {
  @testSetup
  static void setup() {
    // Create test data
    Account account = TestDataService.createAccount('Test Account');
    insert account;

    Contact contact = TestDataService.createContact(
      'Test Contact',
      'test@gmail.com',
      account.Id
    );
    insert contact;

    Guild__c guild = TestDataService.createGuild('Test guild');
    insert guild;

    Hero__c hero = TestDataService.createHero(
      'Test hero',
      contact.Id,
      guild.Id
    );
    Hero__c hero2 = TestDataService.createHero(
      'Test hero2',
      contact.Id,
      guild.Id
    );
    insert new List<Hero__c>{ hero, hero2 };

    Superhero_Mission__c superheroMission = TestDataService.createSuperheroMission(
      'Test subject',
      guild.Id
    );
    insert superheroMission;

    Mission_Assignment__c missionAssignment = TestDataService.createMissionAssignment(
      hero.Id,
      superheroMission.Id
    );
    Mission_Assignment__c missionAssignment2 = TestDataService.createMissionAssignment(
      hero2.Id,
      superheroMission.Id
    );
    insert new List<Mission_Assignment__c>{
      missionAssignment,
      missionAssignment2
    };
  }

  // Check functionality of setting 'Failed' status
  @IsTest
  static void setFailedStatusTest() {
    Superhero_Mission__c superheroMission = [
      SELECT Id
      FROM Superhero_Mission__c
      LIMIT 1
    ];
    Mission_Assignment__c missionAssignmentToUpdate = [
      SELECT Id, Status__c
      FROM Mission_Assignment__c
      LIMIT 1
    ];
    Test.startTest();
    missionAssignmentToUpdate.Status__c = Constants.MISSION_ASSIGNMENT_STATUS_COMPLETED;
    update missionAssignmentToUpdate;
    Test.stopTest();
    Mission_Assignment__c missionAssignment = [
      SELECT Id, Status__c
      FROM Mission_Assignment__c
      WHERE
        Mission__c = :superheroMission.Id
        AND Id != :missionAssignmentToUpdate.Id
    ];

    System.assert(
      missionAssignment.Status__c == Constants.MISSION_ASSIGNMENT_STATUS_FAILED,
      'Mission Assignment Status should be updated to Failed'
    );
  }

  // Test functionality of sending emails
  @IsTest
  static void sendEmailToMissionCreatorTest() {
    Superhero_Mission__c superheroMission = [
      SELECT Id
      FROM Superhero_Mission__c
      LIMIT 1
    ];
    Mission_Assignment__c missionAssignmentToUpdate = [
      SELECT Id, Status__c
      FROM Mission_Assignment__c
      LIMIT 1
    ];
    missionAssignmentToUpdate.Status__c = Constants.MISSION_ASSIGNMENT_STATUS_COMPLETED;

    Boolean isException = false;

    Test.startTest();
    try {
      update missionAssignmentToUpdate;
    } catch (Exception e) {
      isException = true;
    }
    Test.stopTest();

    // Query the EmailMessage records
    List<EmailMessage> sentEmails = [SELECT Id, Status FROM EmailMessage];

    // Assert that emails were sent
    System.assertNotEquals(
      0,
      sentEmails.size(),
      'Email messages should have been sent'
    );

    for (EmailMessage email : sentEmails) {
      // Verify that the email has a 'Sent' status
      System.assertEquals(
        '3',
        email.Status,
        'Email should have a "Sent" status'
      );
    }

    System.assert(
      !isException,
      'Email message should be sent without exceptions'
    );
  }
}
