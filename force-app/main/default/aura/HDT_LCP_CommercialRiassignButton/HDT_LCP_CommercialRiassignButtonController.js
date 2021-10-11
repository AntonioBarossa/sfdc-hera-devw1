({
    refreshpagecontroller : function(component, event, helper) {
        console.log('refreshPageLOL');
        $A.get('e.force:refreshView').fire();
        window.location.reload();
    }
})
