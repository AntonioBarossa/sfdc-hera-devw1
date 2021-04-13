({
    doInit : function(component, event, helper) {
        component.set('v.loading', true);

        var checkprocess = component.get("c.checkCommunityLogin");

        checkprocess.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var res = response.getReturnValue();
                console.log(res);
                var accountId;
                var saleId;
                var campaignId;
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
                        
                    }
                    
                } else {
                    
                    var pageReference = component.get("v.pageReference");
                    accountId = pageReference.state.c__accountId;
                    saleId = pageReference.state.c__saleId ;

                    if(pageReference.state.c__campaignId !== undefined){
                        component.set("v.campaignId", pageReference.state.c__campaignId);
                        campaignId = pageReference.state.c__campaignId;
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

                    if(campaignId !== undefined && campaignId !== ''){
                        saleObject.Campaign__c = campaignId;
                    }

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
