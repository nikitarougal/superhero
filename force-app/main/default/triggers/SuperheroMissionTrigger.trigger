trigger SuperheroMissionTrigger on Superhero_Mission__c(after insert) {
  if (Trigger.isAfter && Trigger.isInsert) {
    SuperheroMissionBatch batch = new SuperheroMissionBatch();

    // Extract and set Superhero Mission IDs from Trigger.new
    for (Superhero_Mission__c mission : Trigger.new) {

      batch.missions.add(mission);
      batch.missionGuildIds.add(mission.Guild__c);
    }

    // Start the batch job
    Id batchInstanceId = Database.executeBatch(batch);
  }
}
