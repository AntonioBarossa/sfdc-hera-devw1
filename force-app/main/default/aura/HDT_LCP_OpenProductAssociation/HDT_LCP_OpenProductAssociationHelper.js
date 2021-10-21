({
	initHelperMethod : function(component, event, helper) {
		console.log('# open from quick action #');

		var objectType = component.get('v.sobjecttype');
        var navService = component.find("navService");
		var recordId = component.get('v.recordId');
		console.log('>>> RECORD ID: ' + recordId);

		var pageReference = {
			type: 'standard__component',
			attributes: {
				componentName: 'c__HDT_LCP_ManageProductAssociation'
			},
			state : {
				c__recordId : recordId,
				c__objType : objectType
			}
		};
		
		navService.navigate(pageReference);
		$A.get("e.force:closeQuickAction").fire();

	},

	getEnabledUser: function(component, event, helper) {
		console.log('# getEnabledUser #');

        var action = component.get("c.getEnabledUser");
        //action.setParams({
        //    productId: productId
        //});

        action.setCallback(this, function (response) {
            var returnObj = response.getReturnValue();
			console.log('# returnObj: ' + returnObj);

			if(returnObj){
				this.initHelperMethod(component, event, helper);
			} else {
				component.set('v.enabled', false);
				console.log('# Your user don\'t have permission');
			}


        });
        $A.enqueueAction(action);
	}

})