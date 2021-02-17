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
    },

    handleSaveEvent : function(component, event, helper){
        var orderParentId = component.get("v.orderParentId");
        var accountId = component.get("v.accountId");
        var venditaId = component.get("v.venditaId");
        helper.redirectToComponent(component,accountId,venditaId,orderParentId);
    }
})
