@isTest
public class HeroServiceTest {
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
  static void testGetHeroByUserId() {
    User user = [SELECT Id FROM User WHERE LastName = 'SuperheroUser'];
    System.runAs(user) {
      // Run the service method
      Hero__c resultHero = HeroService.getHeroByUserId();

      System.assertNotEquals(null, resultHero);
    }
  }
}
