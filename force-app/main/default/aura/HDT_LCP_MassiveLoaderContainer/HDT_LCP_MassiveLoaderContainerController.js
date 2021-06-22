({
    handleGoToRecord : function(component, event, helper) {

        let recordId = event.getParam('recordId');

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });

        navEvt.fire();

    }
})