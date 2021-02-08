({
	initHelperMethod : function(component, event, helper) {
		console.log('# open from quick action #');

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
				var evt = $A.get("e.force:navigateToComponent");
				evt.setParams({
					componentDef : redirectToComponent,
					componentAttributes: {
						recordId : productId
					}
				});
				evt.fire();

			} else {
				console.log('something goes wrong!');
			}


        });
        $A.enqueueAction(action);
	}
})