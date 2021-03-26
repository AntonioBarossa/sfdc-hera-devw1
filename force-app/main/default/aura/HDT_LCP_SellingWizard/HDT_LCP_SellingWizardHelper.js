({
    createSaleRecord : function(component, saleObject) {
        var action = component.get("c.createSale");
        action.setParams({sale : saleObject});
        action.setCallback(this, function(response){
            component.set('v.loading', false);
            var state = response.getState();
            if(state == 'SUCCESS') {
                var newSale = response.getReturnValue();
                component.set('v.sale', newSale);
                component.set('v.saleId', newSale.Id);

                var myPageRef = component.get("v.pageReference");
                var newState = Object.assign({}, myPageRef.state, {c__accountId: component.get("v.recordId"), c__saleId: newSale.Id});
                component.find("navService").navigate({
                    type: myPageRef.type,
                    attributes: myPageRef.attributes,
                    state: newState
                });
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);

    },

    getSaleRecord : function(component) {
        var saleIdParam = component.get("v.saleId");
        var fieldsParam = 'Id,Name,Account__r.Category__c,Account__r.RecordType.DeveloperName,Account__r.Name,Account__r.FiscalCode__c,Account__r.CompanyOwner__c,Account__r.Owner.Name,CurrentStep__c,Status__c,CreatedDate,Agency__c,Market__c,Channel__c,FriendCode__c,CampaignCode__c,CreatedBy__c,SalesCompany__c,Campaign__c';

        var action = component.get("c.getSale");
        action.setParams({id : saleIdParam, fields: fieldsParam});
        action.setCallback(this, function(response){
            component.set('v.loading', false);
            var state = response.getState();
            if(state == 'SUCCESS') {
                var retrievedSale = response.getReturnValue();
                component.set('v.sale', retrievedSale);
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);

    },

    redirectToSObjectSubtab : function(component,objectId,objectApiname){
        var workspaceAPI = component.find("workspace");
        console.log("Begin Redirect");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log("Begin Redirect_2_: " + JSON.stringify(response));
            var focusedTabId = response.parentTabId;
            var focusedTab = response.tabId;
            
            console.log("Begin Redirect_3_: " + focusedTabId);
            console.log("Begin Redirect_4_: " + objectId);
            console.log("Begin Redirect_5_: " + objectApiname);
            
            if (objectApiname == 'Sale__c') {
                console.log('subTab Sale');
                workspaceAPI.openSubtab({//Subtab({
                    parentTabId: focusedTabId,
                    pageReference: {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: objectId,
                            objectApiName: objectApiname,
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
            } else {
                workspaceAPI.openTab({//Subtab({
                    parentTabId: focusedTabId,
                    pageReference: {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: objectId,
                            objectApiName: objectApiname,
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
            }
        })
        .catch(function(error) {
            console.log('******' + error);
        });
        
    }, 
})
