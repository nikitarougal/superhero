@isTest
public class SuperheroMissionTest {
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
  }

  @isTest
  static void testPublicSuperheroMissionTrigger() {
    // test SuperheroMissionTrigger and SuperheroMissionBatch in case Public Superhero Mission has been created
    Guild__c guild = [SELECT Id FROM Guild__c LIMIT 1];
    List<Superhero_Mission__c> missions = new List<Superhero_Mission__c>();

    for (Integer i = 0; i < 100; i++) {
      Superhero_Mission__c superheroMission = TestDataService.createSuperheroMission(
        'Test subject ' + i,
        guild.Id
      );
      superheroMission.Is_Public__c = true;
      missions.add(superheroMission);
    }

    Boolean isException = false;

    Test.startTest();
    try {
      insert missions;
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

    System.assertEquals(
      1,
      [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex']
    );

    System.assert(
      !isException,
      'Email message should be sent without exceptions'
    );
  }

  @isTest
  static void testNotPublicSuperheroMissionTrigger() {
    // test SuperheroMissionTrigger and SuperheroMissionBatch in case Public Superhero Mission has been created
    Guild__c guild = [SELECT Id FROM Guild__c LIMIT 1];

    Superhero_Mission__c superheroMission = TestDataService.createSuperheroMission(
      'Test subject',
      guild.Id
    );

    Boolean isException = false;

    Test.startTest();
    try {
      insert superheroMission;
    } catch (Exception e) {
      isException = true;
    }
    Test.stopTest();

    System.assertEquals(
      1,
      [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex']
    );

    System.assert(
      !isException,
      'Email message should be sent without exceptions'
    );
  }
}
