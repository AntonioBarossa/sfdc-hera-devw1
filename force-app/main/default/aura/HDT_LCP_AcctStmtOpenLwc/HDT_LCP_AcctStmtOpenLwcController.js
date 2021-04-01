({
    doInit : function(component, event, helper) {
        var recordid = component.get("v.pageReference").state.c__recordid;
        //console.log('### isUrlAddressable -> ' + recordid);
        component.set('v.recordid', recordid);
    },

    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('modalbox');
        var cmpBack = component.find('modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
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
                    
                    var cmpTarget = component.find('modalbox');
                    var cmpBack = component.find('modalbackdrop');
                    $A.util.addClass(cmpTarget, 'slds-fade-in-open');
                    $A.util.addClass(cmpBack, 'slds-backdrop--open');

                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                else if (status === "ERROR") {
                    console.error("Error: " + errorMessage);
                }
            }
          );


    }

})