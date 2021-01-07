({
    doInit : function(component, event, helper) {
		let pageRef = component.get("v.pageReference");
        let orderParentId = pageRef.state.c__orderParent;
        let accountId = pageRef.state.c__accountId;
        component.set("v.orderParentId",orderParentId);
        component.set("v.accountId",accountId);
        helper.setColums(component,event,helper);
        helper.helperInit(component,event,helper,orderParentId,accountId);
        
    },
    
    handleRowAction : function(component,event,helper){
        var row = event.getParam('row');
        var action = event.getParam('action');
        console.log("HOLA : " + row.Id);
        console.log("HOLA2 : " + action.value);
        if(action.value == "Avvia Processo"){
            component.set("v.orderId",row.Id);
           	// component.set("v.openModale",true);
        }
    }
    // closeModal : function(component,event,helper){
    //     component.set("v.openModale",false); 
    // },
    // cancel: function(component, event, helper) {
    //     helper.cancelVendite(component);
    // },

    // saveDraft: function(component, event, helper) {
    //     helper.saveDraftHelper(component);
    // },
    // save: function(component, event, helper){
    //   	console.log('Save Lanciato');
    //   	helper.saveOption(component);  
    // }
})
