({
    doInit : function(component, event, helper) {
        helper.setCheckbox(component,event,helper);
        helper.helperInit(component,event,helper);
        
    },

    handleSelezionaProcesso : function(component, event, helper){
        console.log("Hola For Hint:" + component.get("v.selectedValue"));
        helper.setCheckbox(component,event,helper);
    },

    closeModal : function(component,event,helper){
        component.set("v.openModale",false);
    },

    save : function(component,event,helper){
        // helper.saveOp(component,event,helper);
    },

    nextStep : function(component,event,helper){
        component.set("v.recordtypeOrder",component.get("v.selectedValue"));
    }
})
