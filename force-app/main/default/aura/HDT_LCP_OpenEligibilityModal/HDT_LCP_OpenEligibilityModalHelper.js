({
	initHelperMethod : function(component, event, helper) {
		console.log('# open from quick action #');

		var workspaceAPI = component.find("workspace");
		var productId = component.get('v.recordId');
        var action = component.get("c.getExistingCriterion");
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

				workspaceAPI.openTab({
					pageReference: {
						type: "standard__component",
						attributes: {
							componentName: redirectToComponent
						},
						state: {
							c__recordId: productId,
							c__eligibilityId: eligibilityId
						}
					},
					focus: true
				})
				.then(function(response) {
					workspaceAPI.setTabLabel({
						tabId: response,
						label: "Eleggibilità"
					 });
					workspaceAPI.setTabIcon({
						tabId: response,
						icon: 'utility:variation_attribute_setup'
					}).then(function(response){
                        $A.get("e.force:closeQuickAction").fire();
                    });
				})
				.catch(function(error) {
					console.log(error);
				});

			} else {
				console.log('something goes wrong!');
			}

        });
        $A.enqueueAction(action);
	}
})