({
  fetchMissions: function (component) {
    var action = component.get("c.getMissions");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var missions = response.getReturnValue();
        // Handle the retrieved data (e.g., set it to an attribute for your component)
        component.set("v.missions", missions);
      }
    });
    $A.enqueueAction(action);
  }
});
