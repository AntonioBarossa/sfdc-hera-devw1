({

    getRecord: function(component, event, helper) {
		console.log('# open from quick action #');

		var recordId = component.get("v.recordId"); 

		console.log('# recordId from quick action > ' + recordId);

        var action = component.get("c.getAccountDetail");
        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function (response) {
            var returnObj = response.getReturnValue();
            console.log('>>> returnObj ' + returnObj);
            component.set("v.accountId", returnObj);
            helper.openTabWithSubtab(component, event, helper);

        });
        $A.enqueueAction(action);
    }

})