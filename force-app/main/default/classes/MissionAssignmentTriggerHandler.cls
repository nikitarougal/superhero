public class MissionAssignmentTriggerHandler {
  public static void handleCompletion(
    List<Mission_Assignment__c> newAssignments,
    Map<Id, Mission_Assignment__c> oldMap
  ) {
    Set<Id> missionIdsToUpdate = new Set<Id>();

    // Iterate through new assignments to identify completed ones.
    for (Mission_Assignment__c newAssignment : newAssignments) {
      if (
        newAssignment.Status__c == 'Completed' &&
        oldMap.get(newAssignment.Id).Status__c != 'Completed'
      ) {
        missionIdsToUpdate.add(newAssignment.Mission__c);
      }
    }

    // Update other mission assignments as "Failed" for the same mission.
    List<Mission_Assignment__c> otherAssignmentsToUpdate = [
      SELECT Id, Status__c
      FROM Mission_Assignment__c
      WHERE Mission__c IN :missionIdsToUpdate AND Status__c != 'Completed'
    ];

    for (Mission_Assignment__c assignment : otherAssignmentsToUpdate) {
      assignment.Status__c = 'Failed';
    }

    update otherAssignmentsToUpdate;

    // Send emails to mission creator.
    sendEmails(missionIdsToUpdate);
  }

  private static void sendEmails(Set<Id> superheroMissionIds) {
    List<String> emailAddresses = new List<String>();
    List<Superhero_Mission__c> missions = [
      SELECT Id, Owner.Email
      FROM Superhero_Mission__c
      WHERE Id IN :superheroMissionIds
    ];

    for (Superhero_Mission__c mission : missions) {
      if (mission.Owner.Email != null) {
        emailAddresses.add(mission.Owner.Email);
      }
    }

    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(emailAddresses);
    email.setSubject('Mission is Completed');
    email.setPlainTextBody('The Mission you have created is Completed.');
    emails.add(email);

    Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emails);

    if (!emailResults[0].success) {
      throw new CustomEmailException(emailResults[0].errors[0].message);
    }
  }
}
