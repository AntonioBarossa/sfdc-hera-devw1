({
    doInit : function(cmp, event, helper) {
        helper.callApexMethod(cmp, "getScripts").then($A.getCallback(function(scripts){
            cmp.set("v.scripts", scripts);
        }));
    }
})
