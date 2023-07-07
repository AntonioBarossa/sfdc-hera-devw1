({
    init: function(component, event, helper) {
        component.set("v.mySpinner", true);

        var param = component.get("v.recordId");
        component.set("v.myrecordid", param);

        var action = component.get("c.changeRecordTypeOfLead");
         action.setParams({leadId:param });
         action.setCallback(this, function(response)
         {
             var state = response.getState();
             console.log(response.getReturnValue());
         	if (state === "SUCCESS") 
         	{
                console.log("SUCCESS:" + response.getReturnValue());
                let res = response.getReturnValue();
                console.log('res.isCommunity'+res.isCommunity);//--HRAWRM-616   22/09/2021 
                if (res.isCommunity=='false') {

                
                    if(res.comm == 'true' ){    
                        window.open(res.url, "_self");
                    }
                    else{

                    
                        var navEvt = $A.get("e.force:navigateToURL");
                            navEvt.setParams({
                                "url": res.url
                            });
                        navEvt.fire();
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            console.log('******:' + focusedTabId);
                            workspaceAPI.refreshTab({
                                    tabId: focusedTabId,
                                    includeAllSubtabs: true
                            });
                        });
                    

                        /*var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.refreshTab({
                                    tabId: focusedTabId,
                                    includeAllSubtabs: true
                            });
                        });*/

                    }
                    component.set("v.mySpinner", false);

                }
                else{
                    console.log('isCommunity true');
                    component.set("v.isCommunity", true);
                    component.set("v.mySpinner", false);
                    setTimeout(function(){ 
                        $A.get("e.force:closeQuickAction").fire();
                    }, 400);
                   
                   

//--HRAWRM-616   22/09/2021 
                }

         	}
         	else
         	{                
                console.log("Error");
                component.set("v.mySpinner", false);

                var errorMessage = '';

                if(response.getError()[0]){
                    errorMessage = response.getError()[0];
                }
                else{
                    errorMessage = 'Si è verificato un errore durante l\'esecuzione. Verificare e riprovare.'
                }

                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": errorMessage.message
                    });
                toastEvent.fire();

                setTimeout(function(){ 
                    $A.get("e.force:closeQuickAction").fire();
                }, 400);
         	}    
         });
         $A.enqueueAction(action);	
    },
})