({
    handleAccountSearch :function (component, event, helper) {
        var evnt = $A.get("e.force:navigateToComponent");
        evnt.setParams({
            componentDef  : "c:HDT_LCP_ClientArchive",
            //componentDef  : "c:hdtRDOLayout",
            //componentDef  : "c:HDT_LC_RDOLayout",
            componentAttributes: { }
        });
        evnt.fire();
    }
})