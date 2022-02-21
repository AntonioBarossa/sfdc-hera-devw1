({
    handleSubmit: function (component, event, helper) {
        component.find("hdtCampaignMemberAgencyAssignment").handleAssignAgency();
    },

    handleClose: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    showErrorMsg: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var errmsg = event.getParam('errmsg')
        console.log(errmsg);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Attenzione',
            message: errmsg,
            type: 'warning',
            mode: 'sticky'
        });
        toastEvent.fire();
    },

    showSuccess: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var msg = event.getParam('msg')
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: '',
            message: msg,
            type: 'success',
        });
        toastEvent.fire();
    }
})