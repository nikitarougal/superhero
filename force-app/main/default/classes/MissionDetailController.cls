public without sharing class MissionDetailController {
  @AuraEnabled
  public static Superhero_Mission__c getMissionDetails(Id missionId) {
    return [
      SELECT
        Id,
        Name,
        Subject__c,
        Details__c,
        Reward__c,
        Is_Public__c,
        Guild__r.Name,
        (
          SELECT Status__c
          FROM Mission_Assignments__r
        )
      FROM Superhero_Mission__c
      WHERE Id = :missionId
    ];
  }
}
