public class SuperheroMissionBatch implements Database.Batchable<SObject>, Database.Stateful {
  // Store Superhero Mission IDs
  public List<Id> missionGuildIds = new List<Id>();

  public Database.QueryLocator start(Database.BatchableContext context) {
    // query to retrieve the Heros using the stored missionGuildIds.
    System.debug('missionGuildIds: ' + missionGuildIds);
    String query = 'SELECT Contact__r.Email, Guild__r.Id FROM Hero__c WHERE Guild__r.Id IN :missionGuildIds';
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
  }

  public void finish(Database.BatchableContext context) {
  }
}
