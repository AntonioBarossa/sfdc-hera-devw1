({
    doInit: function(component) {
        component.set("v.showSelection", true);
        component.set("v.showAccountBusiness", false);
        component.set("v.showAccountResidenziale", false);
        component.set("v.recordTypeId", "");
    },

    getValueFromLwc : function(component, event, helper) {

        if(event.getParam('selected').DeveloperName == 'HDT_RT_Residenziale'){
            component.set("v.showSelection", false);
            component.set("v.showAccountBusiness", false);
            component.set("v.showAccountResidenziale", true);
            component.set("v.recordTypeId", event.getParam('selected').value);
        }else if(event.getParam('selected').DeveloperName == 'HDT_RT_Business'){
            component.set("v.showSelection", false);
            component.set("v.showAccountResidenziale", false);
            component.set("v.showAccountBusiness", true);
            component.set("v.recordTypeId", event.getParam('selected').value);
        }
    }
})