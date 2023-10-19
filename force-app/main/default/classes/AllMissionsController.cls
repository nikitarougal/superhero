public without sharing class AllMissionsController {
  //get Superhero Missions from the Guild as a current Hero, as well as missions from other guilds (Public)
  @AuraEnabled
  public static List<MissionWrapper> getAllMissions() {
    Id heroId = null;
    Id heroGuild = null;

    Hero__c hero = HeroService.getHeroByUserId();

    if (hero != null) {
      heroId = hero.Id;
      heroGuild = hero.Guild__c;
    }

    List<Superhero_Mission__c> missions = new List<Superhero_Mission__c>(
      [
        SELECT
          Id,
          Complexity_Rank__c,
          Subject__c,
          Guild__r.Name,
          (
            SELECT Status__c, Hero__c
            FROM Mission_Assignments__r
            WHERE Hero__c = :heroId
            LIMIT 1
          )
        FROM Superhero_Mission__c
        WHERE Guild__c = :heroGuild OR Is_Public__c = TRUE
        ORDER BY CreatedDate DESC
      ]
    );
    //wrap missions in the MissionWrapper class
    List<MissionWrapper> missionsWrapper = new List<MissionWrapper>();
    for (Superhero_Mission__c sm : missions) {
      MissionWrapper missionWrapper = new MissionWrapper();
      missionWrapper.id = sm.Id;
      missionWrapper.rank = sm.Complexity_Rank__c;
      missionWrapper.subject = sm.Subject__c;
      missionWrapper.guildName = sm.Guild__r.Name;
      missionWrapper.status = !sm?.Mission_Assignments__r.isEmpty()
        ? sm.Mission_Assignments__r[0].Status__c
        : null;
      missionsWrapper.add(missionWrapper);
    }

    return missionsWrapper;
  }

  public class MissionWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String rank;
    @AuraEnabled
    public String subject;
    @AuraEnabled
    public String guildName;
    @AuraEnabled
    public String status;
  }
}
