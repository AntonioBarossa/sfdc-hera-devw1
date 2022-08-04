({
    doInit : function(component) {

        var pageReference = component.get("v.pageReference").state;
        var recordid = pageReference.c__recordid;
        var type = pageReference.c__type;
        var relatedToId = pageReference.c__relatedtoid;

        component.set('v.recordid', recordid);
        component.set('v.type', type);
        component.set('v.relatedtoid', relatedToId);
    }
})