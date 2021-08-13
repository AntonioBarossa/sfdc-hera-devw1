({
    
    doInit : function(component, event, helper) {
        setTimeout(function(){ component.set("v.loaded", false); }, 500);

           
  
        
    },
    onTabClosed : function(component, event, helper) {
        
        
        
    },
    
    
    
    closedNow : function(component, event, helper) {
        console.log('closedNow');
        component.set("v.loaded",true);

        var yesCampaignMembers= component.find('childlwc').getYesCampaignMembers();
        var accountId=component.find('childlwc').getIdAccount();
        component.set("v.varId",accountId);
        console.log(   'yesCampaignMembers : '+yesCampaignMembers  );
        
        if (yesCampaignMembers) {
            $A.enqueueAction(component.get('c.loadClosedCamp'));

        }
        else{
            
            
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            component.set("v.loaded",false);

        }
    },
    
  
    
 
    
    loadClosedCamp: function (component, event, helper) {
        console.log('loadClosedCamp');
        
        
        var action = component.get("c.methodClosedTab");
        action.setParams({
            "id":component.get("v.varId"),
            "objectName":"Account",
            "category":"Campagna CRM",
            "channel":""
        })
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                console.log(state + 'return : '+response.getReturnValue());
                    var workspaceAPI = component.find("workspace");
                    
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });   
                    if (response.getReturnValue()) {
                        component.set('v.loaded', false);
                        
                        $A.enqueueAction(component.get('c.showToast'));
                        
                    }
                    
                } 
                else {
                    console.log(state);
                }
            });
            $A.enqueueAction(action);
            
        },
    
    goBack: function (component, event, helper) {
        var accountId=component.find('childlwc').getIdAccount();
        component.set("v.varId",accountId);
        var workspaceAPI = component.find("workspace");
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        workspaceAPI.openTab({
            url: '/lightning/r/Account/'+component.get("v.varId")+'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabURL({
                tabId: response
            }).then(function(response) {
                console.log(response);
            });
        })
        .catch(function(error) {
            console.log(error);
        });
        
        
        
    },
    
    
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        component.set("v.reopen", false); 
        toastEvent.setParams({
            "variant": "Success",
            "title": "Success!",
            "message": "Stato impostato a \"Non Proposto Auto\""
        });
        toastEvent.fire();
    }
})