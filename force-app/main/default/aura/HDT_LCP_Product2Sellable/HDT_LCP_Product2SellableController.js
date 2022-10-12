({
    doInit: function(component, event, helper) {
        console.log('# controller init #');
        //helper.initHelperMethod(component, event, helper);
    },

    handleSubmit: function(component, event, helper) {
        console.log('# handleSubmit #');
        component.set('v.spinner', true);
        var oldValue = component.get('v.onLoadValue');

        event.preventDefault();
        var fields = event.getParam('fields');
        console.log('# oldValue: ' + oldValue + ' - newValue: ' + fields.NoSellable__c);
        if(fields.NoSellable__c != oldValue){
            component.find('recordFormId').submit(fields);
        } else {
            $A.get("e.force:closeQuickAction").fire();
        }
        
    },

    handleSuccess: function(component, event) {
        console.log('# handleSuccess #');
        component.set('v.spinner', false);
        $A.get("e.force:closeQuickAction").fire();
    },

    handleCreateLoad: function (component, event, helper) {
        var noSellable = component.find("noSellable").get("v.value");
        console.log('# onload is: ' + noSellable);
        component.set('v.onLoadValue', noSellable);
    },

    handleError: function(component, event, helper) {
        console.log('# onerror #');
        component.set('v.spinner', false);
    }

})