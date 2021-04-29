({
    doInit : function(component, event, helper) {
        var recordid = component.get("v.pageReference").state.c__recordid;
        //console.log('### isUrlAddressable -> ' + recordid);
        component.set('v.recordid', recordid);
    },

    closeModal:function(component,event,helper){
        component.set("v.body", []);
        helper.closeModal(component,event,helper);
    },

    openmodal: function(component,event,helper) {
        console.log('>>> we have to open -> wrts_prcgvr:ServiceCatalogLtgCmp_1_1');

        //console.log('>>> event on aura > ');
        console.log(JSON.stringify(event));
        //var eventDetails = event.getParam('servicecatalogId');
        //console.log('> eventDetails: ' + eventDetails);
        
        var accId = event.getParam('accId');
        var auraFlow = event.getParam('auraFlow');

        if(auraFlow === 'serviceCatalogHandler'){
            helper.createComponent(component, event, helper, accId);
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