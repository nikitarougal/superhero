public class SuperheroMissionBatch implements Database.Batchable<SObject>, Database.Stateful {
  // Store Superhero Mission Guilds IDs and Superhero Missions
  public List<Id> missionGuildIds = new List<Id>();
  public List<Superhero_Mission__c> missions = new List<Superhero_Mission__c>();

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
      System.debug('email: ' + member.Contact__r.Email);
      // Create and add email messages to the list.
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setToAddresses(new List<String>{ member.Contact__r.Email });
      email.setSubject('New Superhero Mission');
      email.setPlainTextBody('A new mission has been assigned to your guild.');
      emails.add(email);
    }

    // Send the collected email messages.
    Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emails);

    if (!emailResults[0].success) {
      throw new CustomEmailException(emailResults[0].errors[0].message);
    }
  }

  public void finish(Database.BatchableContext context) {
  }
}
