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

	}

})