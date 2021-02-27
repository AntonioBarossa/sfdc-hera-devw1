({
	doInit : function(component, event, helper) {
        var recordid = component.get("v.pageReference").state.c__recordId;
        var eligibilityId = component.get("v.pageReference").state.c__eligibilityId;
        
        component.set('v.recordId', recordid);
        component.set('v.eligibilityId', eligibilityId);
	},

    goback : function(component, event, helper) {
        //console.log('# close this aura #');
        //var prodId = event.getParam('prodId');
        //console.log('#  # ' + prodId);
        //component.destroy();
        $A.get('e.force:refreshView').fire();
        /*var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });*/
    }

})