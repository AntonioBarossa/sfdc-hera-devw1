({
    init : function (component, event) {
        var flow = component.find("flowData");
        var inputVariables = [{ name : "recordId", type : "String", value: component.get("v.recordId")}];
        flow.startFlow("HDT_FL_ActivityReminder", inputVariables);
    },

    handleStatusChange : function (component, event) {
        switch (event.getParam("status")) {
            case "FINISHED":
            case "FINISHED_SCREEN":
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Successo",
                    "message": "L'attività è stata sollecitata."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            break;
            case "ERROR":
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Errore",
                    "message": "Si è verificato un errore. Se il problema persiste contattare il supporto tecnico."
                });
                toastEvent.fire();
            break;
        }

        $A.get("e.force:closeQuickAction").fire();
    }
})
