({
    doInit : function(component, event, helper) {
        component.set('v.loading', true);

        var pageReference = component.get("v.pageReference");

        var accountId = pageReference.state.c__accountId;
        component.set("v.recordId", accountId);

        if(pageReference.state.c__saleId != undefined){
            component.set("v.saleId", pageReference.state.c__saleId)
            helper.getSaleRecord(component);
        } else {
            var saleObject = {
                'Account__c' : accountId,
                'Status__c' : 'Bozza',
                'CurrentStep__c' : 1
            };

            helper.createSaleRecord(component, saleObject);
        }

        var workspaceAPI = component.find("workspace");

        workspaceAPI.getFocusedTabInfo().then(function(response3) {
            workspaceAPI.setTabLabel({
            tabId: response3.tabId,
            label: "Wizard Vendita"
        })});
        
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
        helper.redirectToSObjectSubtab(component, saleId, objectApiName);
    },

    handleCancelSaleEvent : function (component, event, helper){
        console.log('HDT_LCP_SellingWizardController - handleCancelSaleEvent');
        var saleId = component.get("v.saleId");
        var objectApiName = 'Sale__c';
        helper.redirectToSObjectSubtab(component, saleId, objectApiName);
    },

    handleSaveSaleEvent : function(component, event, helper){
        var saleId = component.get("v.saleId");
        var objectApiName = 'Sale__c';
        helper.redirectToSObjectSubtab(component, saleId, objectApiName);
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
