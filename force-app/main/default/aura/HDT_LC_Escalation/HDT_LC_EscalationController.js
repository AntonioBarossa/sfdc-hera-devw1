({
    doGetRecordData : function(component, event, helper) {
        var action = component.get("c.getRecordData");
        action.setParams({recordId: component.get("v.recordId")});
        action.setCallback(this, function(response) {
            const data = JSON.parse(response.getReturnValue());
            console.log(data.error);
            if(data.error) {
                console.log(data.error);
            } else {
                component.set("v.parentEntityField", data.parentEntityField);
                component.set("v.recordTypeId", data.recordTypeId);
                component.set("v.showPriorityField", data.showPriorityField);
                if(data.respectCriteria == "true"){
                    component.set("v.showForm", true);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Fallito",
                        "message": data.errorMessage
                    });
                    toastEvent.fire();

                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    onTypeChange: function(component, event, helper) {
        let newValue =  event.getSource().get("v.value") ; 
        component.set("v.showMalfunctionFields", newValue === 'Supporto Anomalia processo/sistema');
    },
    onRecordSubmit: function(component, event, helper) {
        event.preventDefault(); // stop form submission
        component.set("v.showSpinner", true);
        var eventFields = event.getParam("fields");
        eventFields[component.get("v.parentEntityField")] = component.get("v.recordId");
        component.find('recordEditForm').submit(eventFields);
    },
    onSuccess : function(component, event, helper) {
        var record = event.getParam("response");
        var apiName = record.apiName;
        var recordId = record.id;

        // SHOW TOAST
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Successo",
            "message": "Attività di Escalation creata."
        });
        toastEvent.fire();

        //CLOSE MODAL
        $A.get("e.force:closeQuickAction").fire();

        //NAVIGATE TO RECORD
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": recordId,
          "slideDevName": "Details"
        });
        navEvt.fire();
    }
})