({
	cancelDialog: function (component, event, helper) {
		var homeEvt = $A.get("e.force:navigateToObjectHome");
		homeEvt.setParams({
			"scope": "Campaign"
		});
		homeEvt.fire();
	},

	saveRecord: function (component, event, helper) {
		component.find("newCampaignLWC").handleSubmit();
	},

})
