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

    handleRedirectToParent : function(component, event, helper){
        var orderParentId = component.get("v.orderParentId");
        var accountId = component.get("v.accountId");
        var venditaId = component.get("v.venditaId");
        helper.redirectToComponent(component,accountId,venditaId,orderParentId);
    },

    handleEmitLastStep : function(component, event, helper){
        component.set("v.lastStepNumber", event.getParam('lastStepNumber'));
    },

    handleEmitDraftData : function(component, event, helper){
        component.set("v.draftObjectApiName", event.getParam('objectApiName'));
        component.set("v.draftObject", event.getParam('fields'));

        console.log('handleEmitDraftData: ', component.get("v.draftObjectApiName"));
        console.log('handleEmitDraftData: ', JSON.stringify(component.get("v.draftObject")));
    },

    handleEmitDiffDraftData : function(component, event, helper){
        console.log(JSON.stringify(event));
        component.set("v.diffDraftObjectApiName", event.getParam('diffObjectApiName'));
        component.set("v.diffFields", event.getParam('diffFields'));

        console.log('handleEmitDiffDraftData: ', component.get("v.diffDraftObjectApiName"));
        console.log('handleEmitDiffDraftData: ', JSON.stringify(component.get("v.diffFields")));
    }
})
