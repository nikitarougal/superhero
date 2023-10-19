public without sharing class HeroService {
  // get Hero info using current User Id
  public static Hero__c getHeroByUserId() {
    Id userId = UserInfo.getUserId();
    User userWithContact = [
      SELECT ContactId
      FROM User
      WHERE Id = :userId
      LIMIT 1
    ];

    Hero__c hero = null;

    if (userWithContact != null && userWithContact.ContactId != null) {
      hero = [
        SELECT Id, Guild__c, Contact__c, Rank__c
        FROM Hero__c
        WHERE Contact__c = :userWithContact.ContactId
        LIMIT 1
      ];
    }

    return hero;
  }
}
