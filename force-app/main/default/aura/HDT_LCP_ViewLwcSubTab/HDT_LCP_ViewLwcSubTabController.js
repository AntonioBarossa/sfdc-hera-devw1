({
    doInit : function(component) {

        var pageReference = component.get("v.pageReference").state;
        var recordid = pageReference.c__recordid;
        var type = pageReference.c__type;

        component.set('v.recordid', recordid);
        component.set('v.type', type);
    }
})