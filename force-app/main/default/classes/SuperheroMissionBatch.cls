public class SuperheroMissionBatch implements Database.Batchable<SObject>, Database.Stateful {
  // Store Superhero Mission Guilds IDs and Superhero Missions
  public List<Id> missionGuildIds = new List<Id>();
  public List<Superhero_Mission__c> missions = new List<Superhero_Mission__c>();
  public List<String> errors = new List<String>(); // To store error messages

  public Database.QueryLocator start(Database.BatchableContext context) {
    // Add the logic for checking if missions are public or not query to retrieve the Heros using the stored missionGuildIds
    String query;
    for (Superhero_Mission__c mission : missions) {
      if (mission.Is_Public__c) {
        query = 'SELECT Contact__r.Email FROM Hero__c';
      } else {
        query = 'SELECT Contact__r.Email FROM Hero__c WHERE Guild__c IN :missionGuildIds';
      }
    }
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext context, List<Hero__c> scope) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for (Hero__c member : scope) {
      try {
        // Create and add email messages to the list.
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ member.Contact__r.Email });
        email.setSubject('New Superhero Mission');
        email.setPlainTextBody(
          'A new mission has been assigned to your guild.'
        );
        emails.add(email);
      } catch (Exception e) {
        // If an error occurs, log the error message and continue processing
        errors.add(
          'Error processing Hero ' + member.Id + ': ' + e.getMessage()
        );
      }
    }

    // Send the collected email messages.
    Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emails);

    for (Messaging.SendEmailResult result : emailResults) {
      if (!result.success) {
        errors.add('Email sending error: ' + result.errors[0].message);
      }
    }
  }

  public void finish(Database.BatchableContext context) {
    // handle the errors in the 'errors' list.
    if (!errors.isEmpty()) {
      System.debug(
        'Errors occurred during batch processing: ' + String.join(errors, ', ')
      );
    }
  }
}
