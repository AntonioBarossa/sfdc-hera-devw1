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
        
    },

    handleNewServicePoint : function(component, event) {
        var newServicePoint = event.getParam('newServicePoint');
        component.set('v.newServicePoint', newServicePoint);
    }
})
