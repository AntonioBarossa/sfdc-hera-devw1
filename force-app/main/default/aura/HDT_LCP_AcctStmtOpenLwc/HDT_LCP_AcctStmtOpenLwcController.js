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

        var eventDetails = event.getParam('servicecatalogId');
        console.log('> eventDetails: ' + eventDetails);
        
        $A.createComponent(
            'wrts_prcgvr:ServiceCatalogLtgCmp_1_1',
            {recordId: eventDetails},
            function(lwcCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(lwcCmp);
                    component.set("v.body", body);

                    helper.openModal(component,event,helper);

                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                else if (status === "ERROR") {
                    console.error("Error: " + errorMessage);
                }
            }
        );

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