({
	initHelperMethod : function(component, event, helper) {
		console.log('# open from quick action #');

        var navService = component.find("navService");
		var productId = component.get('v.recordId');
		console.log('# productId >> ' + productId);

		var pageReference = {
			type: 'standard__component',
			attributes: {
				componentName: 'c__HDT_LCP_ManageProductAssociation'
			},
			state : {
				c__recordId : productId
			}
		};
		
		navService.navigate(pageReference);
		$A.get("e.force:closeQuickAction").fire();

	},

	/*initHelperMethod2 : function(component, event, helper) {
		console.log('# open from quick action #');

		//var workspaceAPI = component.find("workspace");

        var navService = component.find("navService");
		$A.get("e.force:closeQuickAction").fire();

		var productId = component.get('v.recordId');
		console.log('# productId >> ' + productId);
        var action = component.get("c.getExistingCriteria");
        action.setParams({
            productId: productId
        });

        action.setCallback(this, function (response) {
            var returnObj = response.getReturnValue();
			console.log('# success: ' + returnObj.success);
			
			if(returnObj.success){
				var redirectToComponent = '';
				var eligibilityId = '';
				if(returnObj.recIsPresent){
					//call component for edit existing offer, using lwc
					console.log('# offer Id: ' + returnObj.eligibilityId);
					redirectToComponent = 'c__HDT_LCP_CreateNewEligibilityCriteria';
					eligibilityId = returnObj.eligibilityId;
				} else {
					//call component for create new offer
					console.log('## I have to call a aura cmp');
					redirectToComponent = 'c__HDT_LCP_CreateNewEligibilityCriteria';
				}

				var pageReference = {
					type: 'standard__component',
					attributes: {
						componentName: redirectToComponent
					},
					state : {
						c__recordId : productId,
						c__eligibilityId: eligibilityId
					}
				};
				
				 navService.navigate(pageReference);

			} else {
				console.log('something goes wrong!');
			}

        });
        $A.enqueueAction(action);
	}*/
})