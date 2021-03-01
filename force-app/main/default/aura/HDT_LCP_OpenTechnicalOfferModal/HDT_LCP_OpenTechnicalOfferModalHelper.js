({
	initHelperMethod: function(component, event, helper) {
		console.log('# open from quick action #');

        var navService = component.find("navService");
		var productId = component.get('v.recordId');
		console.log('# productId from quick action > ' + productId);

		var pageReference = {
			type: 'standard__component',
			attributes: {
				componentName: 'c__HDT_LCP_CreateNewTechnicalOffer'
			},
			state : {
				c__recordId : productId
			}
		};
		
		navService.navigate(pageReference);
		$A.get("e.force:closeQuickAction").fire();

	},

	initHelperMethod2: function(component, event, helper) {
		console.log('# open from quick action #');

        var navService = component.find("navService");
		$A.get("e.force:closeQuickAction").fire();

		//var workspaceAPI = component.find("workspace");
		var productId = component.get('v.recordId');

		console.log('# productId from quick action > ' + productId);

        var action = component.get("c.getExistingOffer");
        action.setParams({
            productId: productId
        });

        action.setCallback(this, function (response) {
            var returnObj = response.getReturnValue();
			console.log('# success: ' + returnObj.success);
			
			if(returnObj.success){
				var redirectToComponent = '';
				var technicalOfferId = '';
				if(returnObj.data.offerIsPresent){
					//call component for edit existing offer, using lwc
					console.log('# offer Id: ' + returnObj.data.tecnicalOfferId);
					redirectToComponent = 'c__HDT_LCP_OpenTechnicalOffer';
					technicalOfferId = returnObj.data.tecnicalOfferId;
				} else {
					//call component for create new offer
					console.log('## I have to call a aura cmp');
					redirectToComponent = 'c__HDT_LCP_CreateNewTechnicalOffer';
				}

				

				var pageReference = {
					type: 'standard__component',
					attributes: {
						componentName: redirectToComponent
					},
					state : {
						c__recordId : productId,
						c__technicalOfferId: technicalOfferId
					}
				};
				
				 navService.navigate(pageReference);
				 

				/*workspaceAPI.openTab({
					pageReference: {
						type: "standard__component",
						attributes: {
							componentName: redirectToComponent
						},
						state: {
							c__recordId: productId,
							c__technicalOfferId: technicalOfferId
						}
					},
					focus: true
				})
				.then(function(response) {
					//workspaceAPI.setTabLabel({
					//	tabId: response,
					//	label: "Configura offerta"
					// });
					//workspaceAPI.setTabIcon({
					//	tabId: response,
					//	icon: 'utility:variation_attribute_setup'
					//});
				})
				.catch(function(error) {
					console.log(error);
				});*/



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