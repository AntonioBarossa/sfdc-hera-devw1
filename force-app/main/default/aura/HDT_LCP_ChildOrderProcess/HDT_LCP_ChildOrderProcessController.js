({
    doInit : function(component, event, helper) {
        helper.setCheckbox(component,event,helper);
        helper.helperInit(component,event,helper);
        
    },

    handleSelezionaProcesso : function(component, event, helper){
        helper.setCheckbox(component,event,helper);
    },

    handleRefreshOrderChild : function(component, event, helper){
        helper.refreshOrderChild(component,event,helper);
    },

    save : function(component,event,helper){
        helper.saveOp(component,event,helper);
    },

    nextStep : function(component,event,helper){
        component.set("v.recordtypeOrder",component.get("v.selectedValue"));
    }
})
