({
    doInit : function(component, event, helper) {
        var recordid = component.get("v.pageReference").state.c__recordid;
        //console.log('### isUrlAddressable -> ' + recordid);
        component.set('v.recordid', recordid);
    }
})