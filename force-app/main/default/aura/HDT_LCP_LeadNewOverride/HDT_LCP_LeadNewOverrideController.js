({
	createRecord : function (component, event, helper) {
    	var createRecordEvent = $A.get("e.force:createRecord");
    	createRecordEvent.setParams({
     	   "entityApiName": "Lead",
     	   "defaultFieldValues": {
     	   'Company' : 'Default',
    	}
   	 	});
    	createRecordEvent.fire();
    }
})