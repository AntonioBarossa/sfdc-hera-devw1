({
    doInit : function(cmp, event, helper) {
        helper.callApexMethod(cmp, "getScripts").then($A.getCallback(function(scripts){
            cmp.set("v.scripts", scripts);
        }));
    },
    openScript : function(cmp, event, helper) {
        var scriptId = event.getSource().get("v.value");
        window.open("/"+scriptId);
    }
})
