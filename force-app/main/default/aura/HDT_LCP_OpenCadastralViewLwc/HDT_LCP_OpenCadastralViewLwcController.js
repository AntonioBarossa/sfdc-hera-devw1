({
    doInit : function(component, event, helper) {
        var recordid = component.get("v.pageReference").state.c__recordid;
        component.set('v.recordid', recordid);
    }
})
