({
    doInit : function(component, event, helper) {
        var maximizeButton = document.querySelector('[title="Maximize"]');
        console.log('found maximize '+ maximizeButton);
        console.log('Account Id : ' + component.get("v.servicePointRecord.Account__c"));
        if (maximizeButton) {
            maximizeButton.click();
        }
        var inputVariables = [];
        var flow = component.find("flowData");
        var flowName = 'HDT_FL_PostSalesMasterDispatch';
        var accId = component.get("v.servicePointRecord.Account__c");
        if(accId){
            inputVariables.push({ name : 'AccountId', type : 'String', value : accId });
        }
        inputVariables.push({ name : 'InputServicePointId', type : 'String', value : component.get("v.recordId") });
        inputVariables.push({ name : 'ProcessType', type : 'String', value : 'Informative' });
        inputVariables.push({ name : 'RecordTypeName', type : 'String', value : 'HDT_RT_Informative' });
        inputVariables.push({ name : 'Context', type : 'String', value : 'GlobalAction' });
        flow.startFlow(flowName, inputVariables);
    },

    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED" || event.getParam("status") === "FINISHED_SCREEN") {
            console.log('Flow-Finished');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
    }
})
