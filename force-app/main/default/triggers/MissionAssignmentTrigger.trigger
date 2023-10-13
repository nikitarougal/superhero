trigger MissionAssignmentTrigger on Mission_Assignment__c(after update) {
  if (Trigger.isAfter && Trigger.isUpdate) {
    MissionAssignmentTriggerHandler.handleCompletion(
      Trigger.new,
      Trigger.oldMap
    );
  }
}
