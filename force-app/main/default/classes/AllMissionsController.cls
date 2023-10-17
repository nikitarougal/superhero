public without sharing class AllMissionsController {
  @AuraEnabled
  public static List<Superhero_Mission__c> getMissions() {
    // Get the User Id of the currently logged-in Community User.
    Id userId = UserInfo.getUserId();

    // Query the associated Contact Id for the logged-in User.
    User userWithContact = [
      SELECT ContactId
      FROM User
      WHERE Id = :userId
      LIMIT 1
    ];

    Id heroId = null;

    // Check if a User record with ContactId was found.
    if (userWithContact != null && userWithContact.ContactId != null) {
      // Query the associated Hero Id based on the Contact Id.
      Hero__c hero = [
        SELECT Id
        FROM Hero__c
        WHERE Contact__c = :userWithContact.ContactId
        LIMIT 1
      ];
      if (hero != null) {
        heroId = hero.Id;
      }
    }

    // Now, use the retrieved Hero Id to query relevant Mission records.
    if (heroId != null) {
      List<Superhero_Mission__c> missions = [
        SELECT
          Id,
          Name,
          Subject__c,
          Guild__r.Name,
          Complexity_Rank__c,
          (
            SELECT Status__c, Hero__c
            FROM Mission_Assignments__r
            WHERE Hero__c = :heroId
            LIMIT 1
          )
        FROM Superhero_Mission__c
        ORDER BY CreatedDate DESC
      ];
      return missions;
    }

    // If no Hero Id found, return an empty list.
    return new List<Superhero_Mission__c>();
  }
}
