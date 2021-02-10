({
	initHelperMethod : function(component, event, helper) {
		console.log('# open from quick action #');

		var workspaceAPI = component.find("workspace");
		var productId = component.get('v.recordId');
        var action = component.get("c.getExistingOffer");
        action.setParams({
            productId: productId
        });

        action.setCallback(this, function (response) {
            var returnObj = response.getReturnValue();
			console.log('# success: ' + returnObj.success);
			
			if(returnObj.success){
				var redirectToComponent = '';
				if(returnObj.data.offerIsPresent){
					//call component for edit existing offer, using lwc
					console.log('# offer Id: ' + returnObj.data.tecnicalOfferId);
					redirectToComponent = 'c:HDT_LCP_OpenTechnicalOffer';
				} else {
					//call component for create new offer
					console.log('## I have to call a aura cmp');
					redirectToComponent = 'c:HDT_LCP_CreateNewTechnicalOffer';
				}

				$A.get("e.force:closeQuickAction").fire();


				workspaceAPI.openTab({
					pageReference: {
						type: "standard__component",
						attributes: {
							componentName: 'c__HDT_LCP_CreateNewTechnicalOffer'
						},
						state: {
							c__recordId: productId
						}
					},
					focus: true
				}).then(function(response) {
					workspaceAPI.setTabLabel({
						tabId: response,
						label: "Conf"
					 });
					workspaceAPI.setTabIcon({
						tabId: response,
						icon: 'custom:custom83'
					});
				}).catch(function(error) {
					console.log(error);
				});



				//var evt = $A.get("e.force:navigateToComponent");
				//evt.setParams({
				//	componentDef : redirectToComponent,
				//	componentAttributes: {
				//		recordId : productId
				//	}
				//});
				//evt.fire();

			} else {
				console.log('something goes wrong!');
			}


        });
        $A.enqueueAction(action);
	}
})