({
    doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        console.log(component.get("v.sObjectName"));
        //$A.enqueueAction(component.get('c.loadOpenCamp'));
    },
    
    onTabClosed : function(component, event, helper) {
        var tabId = event.getParam('tabId'); 
        console.log("Tab closed: " + tabId);
        console.log(component.get("v.recordId"));
        
        var workspaceAPI = component.find("workspace");

        workspaceAPI.openTab({
            url: '/lightning/cmp/c__HDT_LCP_Confirmation?c__varId='+component.get("v.recordId"),
            focus: true
        }).then(function(response) {
              // actions to do after opening tab if necessary
              console.log(response);
        }).catch(function(error) {
            console.log(error);
        });

        
    },
 
})