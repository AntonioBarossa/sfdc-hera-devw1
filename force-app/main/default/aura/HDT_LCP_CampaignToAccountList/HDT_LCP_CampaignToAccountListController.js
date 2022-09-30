({
    doInit : function(component, event, helper) {
     
            console.log(component.get("v.recordId"));
            console.log(component.get("v.sObjectName"));
            var workspaceAPI = component.find("workspace");

            workspaceAPI.getEnclosingTabId().then(function(ctabId) {
                console.log(ctabId);
                component.set("v.currentTab", ctabId);
            })
            
        var action = component.get("c.getCurrUserRole");
        action.setCallback(this, function(response) {
            var isFront = (response.getReturnValue());
            if(isFront!=null){
                component.set("v.isFrontUser", isFront);
            }
        });
        $A.enqueueAction(action);
    },
    
    onTabClosed : function(component, event, helper) {
        if(component.get("v.isFrontUser")){
            var tabId = event.getParam('tabId'); 
            console.log("Tab closed: " + tabId);
            console.log("Tab Current: " +component.get("v.currentTab"));
            console.log(component.get("v.recordId"));
            
            var workspaceAPI = component.find("workspace");       
            
            if (tabId==component.get("v.currentTab") &&!tabId.includes('_')) {

                workspaceAPI.openTab({
                    url: '/lightning/cmp/c__HDT_LCP_Confirmation?c__varId='+component.get("v.recordId"),
                    focus: true
                }).then(function(response) {
                    // actions to do after opening tab if necessary
                    console.log(response);
                }).catch(function(error) {
                    console.log(error);
                });
            }
        }        
    },
})