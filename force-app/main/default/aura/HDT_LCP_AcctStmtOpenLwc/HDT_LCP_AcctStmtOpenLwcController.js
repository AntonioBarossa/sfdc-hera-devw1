({
    doInit : function(component, event, helper) {
        var recordid = component.get("v.pageReference").state.c__recordid;
        var tab = component.get("v.pageReference").state.c__tab;
        var defaultRequestObj = component.get("v.pageReference").state.c__defaultRequestObj;
        component.set('v.recordid', recordid);
        component.set('v.tab', tab);
        //component.set('v.defaultRequestObj', '{"servizio":"10","contratto":"3025603142"}');
        component.set('v.defaultRequestObj', defaultRequestObj);
        helper.getEnclosingTabId(component, event, helper);
    },

    closeModal:function(component,event,helper){
        component.set("v.body", []);
        helper.closeModal(component,event,helper);
    },

    openmodal: function(component,event,helper) {
        console.log('>>> we have to open a modal');
        //console.log('>>> EVENT FROM LWC > ' + JSON.stringify(event));

        var auraFlow = event.getParam('auraFlow');

        if(auraFlow === 'serviceCatalogHandler'){
            helper.createComponent(component, event, helper);
        } else if(auraFlow === 'runFlowFromAura'){
            helper.openSubTab(component, event, helper);
        }

    },

    change: function(component,event,helper) {
        console.log('>>> change action...');
        component.set("v.body", []);
        helper.closeModal(component,event,helper);
    },

    locationChange: function(component,event,helper) {
        console.log('>>> locationChange action...');
        component.set("v.body", []);
        helper.closeModal(component,event,helper);
    },

    onTabClosed : function(component, event, helper) {
        var tabId = event.getParam('tabId');
        console.log("Tab closed: " + tabId);
    } 

})