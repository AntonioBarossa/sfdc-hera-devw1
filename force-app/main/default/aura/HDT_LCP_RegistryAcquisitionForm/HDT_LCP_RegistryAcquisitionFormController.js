({
    createRecord : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Lead",
            "defaultFieldValues": {
       			 'Company' : 'Default' 
    		}
        });
        createRecordEvent.fire();
    },
    handleAccountCreation :function (component, event, helper) {
        var evnt = $A.get("e.force:navigateToComponent");
        evnt.setParams({
            componentDef  : "c:HDT_LCP_AccountNewOverride",
            componentAttributes: { }
        });
        evnt.fire();
    }
})