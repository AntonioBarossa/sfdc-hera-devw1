({
    refreshpagecontroller : function(component, event, helper) {
        console.log('refreshPageLOL');
        $A.get('e.force:refreshView').fire();
        window.location.reload();
    },
    assignerUpdated : function(component, event, helper){
        setTimeout(function(){window.location.reload()},1000);
    }
})
