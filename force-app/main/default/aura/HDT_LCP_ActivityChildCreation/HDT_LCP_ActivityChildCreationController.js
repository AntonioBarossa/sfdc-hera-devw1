({
    init: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var activityId = myPageRef.state.c__activityId;
        var tipology = myPageRef.state.c__tipology;
        var workspaceAPI = cmp.find("workspace");
        var action = cmp.get("c.createActivityChild");
         action.setParams({ activityId : activityId,
                            tipology : tipology
                        });
         action.setCallback(this, function(response)
         {
             var state = response.getState();
             var valueId= response.getReturnValue();
             console.log(response.getReturnValue());
         	if (state === "SUCCESS") 
         	{
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.parentTabId;
                    var focusedTab = response.tabId;
                    workspaceAPI.openTab({
                        pageReference: {
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: valueId,
                                objectApiName:'wrts_prcgvr__Activity__c',
                                actionName : 'view'
                            }
                        },
                        focus: true
                    }).then(function(response2){
                        workspaceAPI.closeTab({tabId: focusedTab});
                    })
                    .catch(function(error) {
                        console.log('******' + error);
                    });
                })
                .catch(function(error) {
                    console.log('******' + error);
                });
                
            
         	}else{
                console.log("Error");
         	}    
         });
         $A.enqueueAction(action);	

    }
})