@IsTest
private class AllMissionsControllerTest {
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
    Superhero_Mission__c publicSuperheroMission = TestDataService.createSuperheroMission(
      'Test subject2',
      guild.Id
    );
    insert new List<Superhero_Mission__c>{
      superheroMission,
      publicSuperheroMission
    };
  }

  // Test Controller method retrieving all accessible missions
  @IsTest
  static void getAllMissionsTest() {
    User user = [SELECT Id FROM User WHERE LastName = 'SuperheroUser'];
    System.runAs(user) {
      List<AllMissionsController.MissionWrapper> superheroMissions = AllMissionsController.getAllMissions();
      System.assert(
        superheroMissions.size() == 2,
        'Should be found two missions'
      );
    }
  }
}
