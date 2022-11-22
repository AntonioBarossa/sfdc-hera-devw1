({
    doInit : function(component, event, helper) {
        var recordid = component.get("v.pageReference").state.c__recordid;
        var sObjectType = component.get("v.pageReference").state.c__sObjectType;
        console.log('>>recordId', recordid);
        console.log('>>sObjectType', sObjectType);
        component.set('v.recordid', recordid);
        component.set('v.sObjectType', sObjectType);
    }
})
