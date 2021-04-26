({
    doInit: function (component, event, helper) {

    },

    afterSubmit: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})
