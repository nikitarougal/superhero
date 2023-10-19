public without sharing class MissionDetailController {
  // get information about a current Hero and wrap it to HeroDetailsWrapper wrapper
  @AuraEnabled
  public static HeroDetailsWrapper getHeroDetails() {
    Hero__c hero = HeroService.getHeroByUserId();

    HeroDetailsWrapper heroDetailsWrapper = new HeroDetailsWrapper();
    heroDetailsWrapper.id = hero.Id;
    heroDetailsWrapper.guild = hero.Guild__c;
    heroDetailsWrapper.contact = hero.Contact__c;
    heroDetailsWrapper.rank = hero.Rank__c;

    return heroDetailsWrapper;
  }

  // get Superhero Mission and Mission Assignments by Id
  @AuraEnabled
  public static MissionDetailsWrapper getMissionDetails(
    String recordId,
    String heroId
  ) {
    Superhero_Mission__c mission = [
      SELECT
        Id,
        Subject__c,
        Details__c,
        Complexity_Rank__c,
        Reward__c,
        Deadline__c,
        Guild__r.Name,
        (
          SELECT Status__c
          FROM Mission_Assignments__r
          WHERE Hero__c = :heroId
          LIMIT 1
        )
      FROM Superhero_Mission__c
      WHERE Id = :recordId
      LIMIT 1
    ];

    MissionDetailsWrapper missionDetailsWrapper = new MissionDetailsWrapper();
    missionDetailsWrapper.id = mission.Id;
    missionDetailsWrapper.subject = mission.Subject__c;
    missionDetailsWrapper.details = mission.Details__c;
    missionDetailsWrapper.rank = mission.Complexity_Rank__c;
    missionDetailsWrapper.reward = mission.Reward__c;
    missionDetailsWrapper.deadline = mission.Deadline__c;
    missionDetailsWrapper.guild = mission.Guild__r.Name;
    missionDetailsWrapper.status = !mission?.Mission_Assignments__r.isEmpty()
      ? mission.Mission_Assignments__r[0].Status__c
      : null;

    return missionDetailsWrapper;
  }

  // check if current Hero has less than 3 unfinished Mission Assignments
  @AuraEnabled
  public static Boolean checkHeroMissionAssignments(String heroId) {
    List<Mission_Assignment__c> missionAssignments = [
      SELECT Id
      FROM Mission_Assignment__c
      WHERE Hero__c = :heroId AND Status__c = 'In Progress'
    ];

    return missionAssignments.size() < 3;
  }

  // create a new Mission Assignment
  @AuraEnabled
  public static Id createMissionAssignment(String heroId, String missionId) {
    Mission_Assignment__c newMissionAssignment = new Mission_Assignment__c();
    newMissionAssignment.Hero__c = heroId;
    newMissionAssignment.Mission__c = missionId;
    insert newMissionAssignment;

    return newMissionAssignment.Id;
  }

  // update of existing Mission Assignment
  @AuraEnabled
  public static Id updateMissionAssignment(String heroId, String missionId) {
    Mission_Assignment__c missionAssignment = [
      SELECT Id, Status__c
      FROM Mission_Assignment__c
      WHERE
        Mission__c = :missionId
        AND Hero__c = :heroId
        AND Status__c = 'In Progress'
      LIMIT 1
    ];

    missionAssignment.Status__c = 'Completed';
    update missionAssignment;

    return missionAssignment.Id;
  }

  // get All Possible values from Rank field on Superhero Mission object
  @AuraEnabled
  public static List<String> getAllPossibleRanks() {
    List<String> rankFieldValues = new List<String>();
    Schema.DescribeFieldResult fieldResult = Superhero_Mission__c.Complexity_Rank__c.getDescribe();
    for (Schema.PicklistEntry valueResult : fieldResult.getPicklistValues()) {
      rankFieldValues.add(valueResult.getValue());
    }
    return rankFieldValues;
  }

  public class MissionDetailsWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String subject;
    @AuraEnabled
    public String details;
    @AuraEnabled
    public String rank;
    @AuraEnabled
    public Decimal reward;
    @AuraEnabled
    public Date deadline;
    @AuraEnabled
    public String guild;
    @AuraEnabled
    public String status;
  }

  public class HeroDetailsWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String guild;
    @AuraEnabled
    public String contact;
    @AuraEnabled
    public String rank;
  }
}
