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
                if (component.get('v.isCommunity')){
                    const url = new URL(window.location.href);
                    console.log('url' + url);
                    url.searchParams.set('c__saleId', component.get('v.saleId'));
                    window.history.replaceState(null, null, url);

                } else {

                var myPageRef = component.get("v.pageReference");
                var newState = Object.assign({}, myPageRef.state, {c__accountId: component.get("v.recordId"), c__saleId: component.get('v.saleId')});
                component.find("navService").navigate({
                    type: myPageRef.type,
                    attributes: myPageRef.attributes,
                    state: newState
                });
                }
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);

    },

    getSaleRecord : function(component) {
        var saleIdParam = component.get("v.saleId");
        var fieldsParam = 'Id,Name,Account__r.Category__c,Account__r.RecordType.DeveloperName,Account__r.Name,Account__r.FiscalCode__c,Account__r.CompanyOwner__c,Account__r.Owner.Name,CurrentStep__c,Status__c,CreatedDate,Agency__c,Market__c,Channel__c,FriendCode__c,CampaignCode__c,CreatedBy__c,SalesCompany__c,Campaign__c,CreatedBy.LoginChannel__c,CreatedBy.Station__c,CreatedBy.CreatorGroup__c';

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
            
            console.log("focusedTab: " + focusedTab);
            console.log("objectId: " + objectId);
            console.log("objectApiname: " + objectApiname);
            
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
        })
        .catch(function(error) {
            console.log('******' + error);
        });
        
    },

    redirectToRecordPageCommunity : function(objectId){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
        "recordId": objectId
        });
        navEvt.fire();
    }
})
