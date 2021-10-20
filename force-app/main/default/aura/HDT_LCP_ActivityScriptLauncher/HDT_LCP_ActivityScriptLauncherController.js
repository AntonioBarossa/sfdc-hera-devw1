({
    handleCloseAction : function(cmp, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();

        $A.get('e.force:refreshView').fire();
    },
    handleResultEvent: function(component, event, helper) {

        console.log('handleResultEvent: ' + event.getParam('orderId'));

        /*helper.redirectToSObjectSubtab(component,event.getParam('orderId'),'Order');
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();*/
    }
})
