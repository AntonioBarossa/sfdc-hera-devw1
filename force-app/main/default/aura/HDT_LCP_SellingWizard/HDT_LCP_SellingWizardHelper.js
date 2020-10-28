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

                var myPageRef = component.get("v.pageReference");
                component.find("navService").navigate({
                    type: myPageRef.type,
                    attributes: myPageRef.attributes,
                    state: {
                        c__accountId: component.get("v.recordId"),
                        c__saleId: newSale.Id
                    }
                });
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);

    },

    getSaleRecord : function(component) {
        var saleIdParam = component.get("v.saleId");
        var fieldsParam = 'Id,Name,Account__r.Name,Account__r.FiscalCode__c,CreatedDate';

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

    }
})
