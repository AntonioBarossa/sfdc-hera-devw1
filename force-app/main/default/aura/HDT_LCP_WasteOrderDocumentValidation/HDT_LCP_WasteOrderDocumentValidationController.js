({
    handleComplete: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },

    handleCancel: function (component, event, helper) {
        //close the modal
        $A.get("e.force:closeQuickAction").fire();
        //$A.get('e.force:refreshView').fire();
    }
})
