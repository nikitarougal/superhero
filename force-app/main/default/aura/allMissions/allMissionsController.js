({
  doInit: function (component, event, helper) {
    // Fetch mission data from your Salesforce org
    helper.fetchMissions(component);
  }
});
