@isTest
public class TestDataService {
  // create Account
  public static Account createAccount(String name) {
    Account portalAccount = new Account();
    portalAccount.Name = name;
    return portalAccount;
  }

  // create Contact
  public static Contact createContact(
    String lastName,
    String email,
    Id accountId
  ) {
    Contact portalContact = new contact();
    portalContact.LastName = lastName;
    portalContact.Email = email;
    portalContact.AccountId = accountId;
    return portalContact;
  }

  // create Contact
  public static Contact createContact(String lastName) {
    Contact contact = new Contact();
    contact.LastName = lastName;
    return contact;
  }

  // create Hero
  public static Hero__c createHero(String name, Id contactId, Id guildId) {
    Hero__c hero = new Hero__c();
    hero.Name = name;
    hero.Contact__c = contactId;
    hero.Guild__c = guildId;
    return hero;
  }

  // create Guild
  public static Guild__c createGuild(String name) {
    Guild__c guild = new Guild__c();
    guild.Name = name;
    return guild;
  }

  // create Superhero Mission
  public static Superhero_Mission__c createSuperheroMission(
    String subject,
    Id guildId
  ) {
    Superhero_Mission__c superheroMission = new Superhero_Mission__c();
    superheroMission.Guild__c = guildId;
    superheroMission.Subject__c = subject;
    superheroMission.Details__c = subject;
    return superheroMission;
  }

  // create Mission Assignment
  public static Mission_Assignment__c createMissionAssignment(
    Id heroId,
    Id missionId
  ) {
    Mission_Assignment__c missionAssignment = new Mission_Assignment__c();
    missionAssignment.Hero__c = heroId;
    missionAssignment.Mission__c = missionId;
    return missionAssignment;
  }

  // create Commuinity User
  public static User createCommunityUser(
    String contactId,
    String profileId,
    String firstName,
    String lastName
  ) {
    User user = new User();
    user.ProfileId = profileId;
    user.FirstName = firstName + String.valueOf(System.today());
    user.LastName = lastName;
    user.Email = 'test@test.com';
    user.Username = String.valueOf(System.today()) + '@gmail.com.test';
    user.Alias = 'alias';
    user.TimeZoneSidKey = 'America/Los_Angeles';
    user.LanguageLocaleKey = 'en_US';
    user.LocaleSidKey = 'en_US';
    user.EmailEncodingKey = 'UTF-8';
    user.ContactId = contactId;

    return user;
  }
}
