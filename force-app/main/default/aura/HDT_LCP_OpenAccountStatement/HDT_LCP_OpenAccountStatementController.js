({
    openTabWithSubtab : function(component, event, helper) {

        var workspaceAPI = component.find("workspace");

        workspaceAPI.getFocusedTabInfo().then(function(response) {
            
            console.log(JSON.stringify('Current subTab > ' + response.isSubtab));
            
            if(response.isSubtab){
                /*var currentComponentName = response.pageReference.attributes.componentName;
                console.log(JSON.stringify(response.pageReference));
                if(currentComponentName!= undefined && currentComponentName==='c__HDT_LCP_AcctStmtOpenLwc'){

                    $A.get("e.force:closeQuickAction").fire();

                } else {*/
                    var currentComponentName = 'c__HDT_LCP_AcctStmtOpenLwc';
                    workspaceAPI.getTabInfo({
                        tabId: response.parentTabId
                    }).then(function(resp) {
                        var compList = [];
                        for(var i = 0; i < resp.subtabs.length; i++){
                            compList.push(resp.subtabs[i].pageReference.attributes.componentName);
                        }
                        
                        var n = compList.includes(currentComponentName);
                        console.log('>>>>>>>>> ' + n);

                        if(!n){
                            helper.openSubTab(component, event, helper);
                        } else {
                            $A.get("e.force:closeQuickAction").fire();
                        }

                    });
                                    
                //}
                
            } else {
                helper.openSubTab(component, event, helper);
            }

       }).catch(function(error) {
            console.log(error);
        });

    }

})