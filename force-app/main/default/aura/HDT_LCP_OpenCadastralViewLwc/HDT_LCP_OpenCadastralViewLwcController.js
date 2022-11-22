({
    doInit : function(component, event, helper) {
        console.log('>>state', JSON.stringify(component.get("v.pageReference").state));
        var recordid = component.get("v.pageReference").state.c__recordid;
        var sObjectType = component.get("v.pageReference").state.c__sobjecttype;
        console.log('>>recordId', recordid);
        console.log('>>sObjectType', sObjectType);
        component.set('v.recordid', recordid);
        component.set('v.sObjectType', sObjectType);
    }
})
