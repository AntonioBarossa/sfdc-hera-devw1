({
    doInit : function(component, event, helper) {
        var maximizeButton = document.querySelector('[title="Maximize"]');
        console.log('found maximize '+ maximizeButton);
        if (maximizeButton) {
            maximizeButton.click();
        }
        var inputVariables = [];
        var flow = component.find("flowData");
        var flowName = 'HDT_FL_DispatchTari';
        inputVariables.push({ name : 'ProcessType', type : 'String', value : 'Segnalazioni Ambientali' });
        inputVariables.push({ name : 'RecordTypeName', type : 'String', value : 'HDT_RT_Segnalazioni' });
      	flow.startFlow(flowName, inputVariables);
    },

    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED" || event.getParam("status") === "FINISHED_SCREEN") {
            console.log('Flow-Finished');
            var flowfinal = component.find("flowData");
			flowfinal.destroy();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
    }
})