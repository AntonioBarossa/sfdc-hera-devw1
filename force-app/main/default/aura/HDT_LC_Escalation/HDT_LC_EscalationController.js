({
    doGetRecordData : function(component, event, helper) {
        var action = component.get("c.getRecordData");
        action.setParams({recordId: component.get("v.recordId")});
        action.setCallback(this, function(response) {
            const data = JSON.parse(response.getReturnValue());
            if(data.error) {
                console.log(data.error);
            } else {
                component.set("v.parentEntityField", data.parentEntityField);
                component.set("v.recordTypeId", data.recordTypeId);
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
        var eventFields = event.getParam("fields");
        eventFields[component.get("v.parentEntityField")] = component.get("v.recordId");
        eventFields["RecordTypeId"] = component.get("v.recordTypeId");
        component.find('recordEditForm').submit(eventFields);

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
    }
})






