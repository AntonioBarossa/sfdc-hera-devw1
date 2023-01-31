({
    doInit : function(component, event, helper) {
        var maximizeButton = document.querySelector('[title="Maximize"]');
        console.log('found maximize '+ maximizeButton);
        if (maximizeButton) {
            maximizeButton.click();
        }
        var inputVariables = [];
        var flow = component.find("flowData");
        var flowName = 'HDT_FL_PostSalesMasterDispatch';
        inputVariables.push({ name : 'ProcessType', type : 'String', value : 'Reclamo Scritto Da Cittadino' });
        inputVariables.push({ name : 'RecordTypeName', type : 'String', value : 'HDT_RT_ReclamoDaCittadino' });
        inputVariables.push({ name : 'Context', type : 'String', value : 'GlobalAction' });
      	flow.startFlow(flowName, inputVariables);
    },

    handleStatusChange : function (component, event) {
        console.log('@@@@'+JSON.stringify(event));
        if(event.getParam("status") === "FINISHED" || event.getParam("status") === "FINISHED_SCREEN") {
            console.log('Flow-Finished');
            var flowfinal = component.find("flowData");
            flowfinal.destroy();
            $A.get("e.force:closeQuickAction").fire();
        }
    }
})