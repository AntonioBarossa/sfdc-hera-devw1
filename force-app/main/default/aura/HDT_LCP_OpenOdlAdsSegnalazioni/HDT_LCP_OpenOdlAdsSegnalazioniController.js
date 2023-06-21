({

    getRecord: function(component, event, helper) {
		    console.log('# open from quick action #');
        
        helper.openTabWithSubtab(component, event, helper);
    }

})