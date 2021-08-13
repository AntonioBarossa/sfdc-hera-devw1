({
    
    doInit : function(component, event, helper) {
        console.log('doinit');
        setTimeout(function(){ 
            
            
            
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            testParam = '';
            var varId;
            
            
            
            for(let i = 0; i < sURLVariables.length; i++){
                
                testParam = '';
                testParam = sURLVariables[i].split('=');
                
                
                if (testParam[i] == 'c__varId'){
                    console.log(testParam[i]);
                    console.log(testParam[i+1]);
                    varId = testParam[i+1];
                }
                
            }
            component.set("v.varId", varId);
            
        }, 200);
        
        
    },
    onTabClosed : function(component, event, helper) {
        
        
        
    },
    
    
    
    closedNow : function(component, event, helper) {
        component.set('v.loaded', true);
        console.log('varID : '+component.get("v.varId"));
        
        $A.enqueueAction(component.get('c.loadClosedCamp'));
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
                    });    }
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
    