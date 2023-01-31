({
    doInit : function(component, event, helper) {
        component.set('v.loading', true);

        var campaignId = '';

        var checkprocess = component.get("c.checkCommunityLogin");

        checkprocess.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var res = response.getReturnValue();
                console.log(res);
                var accountId;
                var saleId;
                var campaignId;
                var campaignMemberId;
                var campaignCommissioningId;
                var interactionId;
                component.set('v.isCommunity', res);
                console.log('res*****' + res);
                if (res){

                    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                        sURLVariables = sPageURL.split('&'),
                        testParam = '';
                    
                    for(let i = 0; i < sURLVariables.length; i++){
                        
                        testParam = '';
                        testParam = sURLVariables[i].split('=');
                        
                     
                        if (testParam[0] == 'c__accountId'){
                            accountId = testParam[1];
                        }

                        if (testParam[0] == 'c__saleId'){
                            saleId = testParam[1];
                        }

                        if (testParam[0] == 'c__campaignId'){
                            campaignId = testParam[1];
                            component.set("v.campaignId", campaignId);
                        }
                        if (testParam[0] == 'c__campaignCommissioningId'){
                            campaignCommissioningId = testParam[1];
                            component.set("v.campaignCommissioningId", campaignCommissioningId);
                        }
                        if (testParam[0] == 'c__campaignMemberId'){
                            campaignMemberId = testParam[1];
                            component.set("v.campaignMemberId", campaignMemberId);
                        }
                        
                    }
                    
                } else {
                    
                    var pageReference = component.get("v.pageReference");
                    accountId = pageReference.state.c__accountId;
                    saleId = pageReference.state.c__saleId ;

                    console.log('pageReference*****' + pageReference);

                    if(pageReference.state.c__campaignId !== undefined){
                        component.set("v.campaignId", pageReference.state.c__campaignId);
                        campaignId = pageReference.state.c__campaignId;
                    }

                    if(pageReference.state.c__campaignMemberId !== undefined){
                        component.set("v.campaignMemberId", pageReference.state.c__campaignMemberId);
                        campaignMemberId = pageReference.state.c__campaignMemberId;
                    }

                    if(pageReference.state.c__interactionId !== undefined){
                        //component.set("v.campaignMemberId", pageReference.state.c__campaignMemberId);
                        interactionId = pageReference.state.c__interactionId;
                    }

                }
                
                component.set("v.recordId", accountId);
        
                if(saleId != undefined){
                    component.set("v.saleId", saleId);
                    helper.getSaleRecord(component);
                } else {
                    var saleObject = {
                        'Account__c' : accountId,
                        'Status__c' : 'Bozza',
                        'CurrentStep__c' : 1
                        
                    };

                    if(interactionId !== undefined && interactionId !== ''){
                        saleObject.Interaction__c = interactionId;
                    }

                    if(campaignId !== undefined && campaignId !== ''){
                        saleObject.Campaign__c = campaignId;
                    }

                    helper.createSaleRecord(component, saleObject);
                } 
            } 
        });

        var checkprocess = component.get("c.checkCommunityLogin");

        checkprocess.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var res = response.getReturnValue();
                console.log(res);
                var accountId;
                var saleId;
                var campaignId;
                var campaignMemberId;
                var interactionId;
                component.set('v.isCommunity', res);

                if (res){

                    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                        sURLVariables = sPageURL.split('&'),
                        testParam = '';
                    
                    for(let i = 0; i < sURLVariables.length; i++){
                        
                        testParam = '';
                        testParam = sURLVariables[i].split('=');
                        
                     
                        if (testParam[0] == 'c__accountId'){
                            accountId = testParam[1];
                        }

                        if (testParam[0] == 'c__saleId'){
                            saleId = testParam[1];
                        }

                        if (testParam[0] == 'c__campaignId'){
                            campaignId = testParam[1];
                            component.set("v.campaignId", campaignId);
                        }
                        if (testParam[0] == 'c__campaignMemberId'){
                            campaignMemberId = testParam[1];
                            component.set("v.campaignMemberId", campaignMemberId);
                        }
                        
                    }
                    
                } else {
                    
                    var pageReference = component.get("v.pageReference");
                    accountId = pageReference.state.c__accountId;
                    saleId = pageReference.state.c__saleId ;

                    console.log('pageReference*****' + pageReference);

                    if(pageReference.state.c__campaignId !== undefined){
                        component.set("v.campaignId", pageReference.state.c__campaignId);
                        campaignId = pageReference.state.c__campaignId;
                    }
                    if(pageReference.state.c__campaignMemberId !== undefined){
                        component.set("v.campaignMemberId", pageReference.state.c__campaignMemberId);
                        campaignMemberId = pageReference.state.c__campaignMemberId;
                    }
                    
                    console.log('pageReference.state.c__interactionId*****' + pageReference.state.c__interactionId);
                    if(pageReference.state.c__interactionId !== undefined){
                        //component.set("v.campaignMemberId", pageReference.state.c__campaignMemberId);
                        interactionId = pageReference.state.c__interactionId;
                    }
                    console.log('interactionId*****' + interactionId);

                }

                component.set("v.recordId", accountId);
                if(component.get('v.recordId') != undefined){
                    helper.getCustomerCode(component);
                }

                
                if(saleId != undefined){
                    component.set("v.saleId", saleId);
                    helper.getSaleRecord(component);
                } else {
                    var saleObject = {
                        'Account__c' : accountId,
                        'Status__c' : 'Bozza',
                        'CurrentStep__c' : 1,
                        'Campaign__c' : campaignId,
                        'Interaction__c': interactionId
                    };
                    helper.createSaleRecord(component, saleObject);
                } 
            } 
        });
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response3) {
            workspaceAPI.setTabLabel({
                tabId: response3.tabId,
                label: "Wizard Vendita"
            })});      
        
        $A.enqueueAction(checkprocess);
    },

    handleNewServicePoint : function(component, event) {
        var newServicePoint = event.getParam('newServicePoint');
        component.set('v.newServicePoint', newServicePoint);
    },

    handleNewTileEvent : function(component){
        var hdtConfigureProduct = component.find("hdtConfigureProduct");
        hdtConfigureProduct.getQuotesData();
    },

    handleTileDeleteEvent : function(component){
        var hdtConfigureProduct = component.find("hdtConfigureProduct");
        hdtConfigureProduct.getQuotesData();
    },

    handleQuoteCancelEvent : function(component){
        var hdtSaleServiceContainer = component.find("hdtSaleServiceContainer");
        hdtSaleServiceContainer.refreshTileData();
    },

    handleSaleUpdateEvent : function(component, event, helper) {
        helper.getSaleRecord(component);
    },

    handleSaveDraftEvent : function(component, event, helper) {
        var saleId = component.get("v.saleId");
        var objectApiName = 'Sale__c';

        if(component.get("v.isCommunity")){
            helper.redirectToRecordPageCommunity(saleId);
        } else {
            helper.redirectToSObjectSubtab(component, saleId, objectApiName);
        }
    },

    handleCancelSaleEvent : function (component, event, helper){
        var saleId = component.get("v.saleId");
        var objectApiName = 'Sale__c';
        
        if(component.get("v.isCommunity")){
            helper.redirectToRecordPageCommunity(saleId);
        } else {
            helper.redirectToSObjectSubtab(component, saleId, objectApiName);
        }
    },

    handleSaveSaleEvent : function(component, event, helper){
        var saleId = component.get("v.saleId");
        var objectApiName = 'Sale__c';

        if(component.get("v.isCommunity")){
            helper.redirectToRecordPageCommunity(saleId);
        } else {
            helper.redirectToSObjectSubtab(component, saleId, objectApiName);
        }
    },

    handleRefreshProductsTable : function(component, event, helper){
        var hdtConfigureProduct = component.find("hdtConfigureProduct");
        hdtConfigureProduct.getQuotesData();
    },

    handleTileRefresh : function(component){
        var hdtSaleServiceContainer = component.find("hdtSaleServiceContainer");
        hdtSaleServiceContainer.refreshTileData();
    },
})