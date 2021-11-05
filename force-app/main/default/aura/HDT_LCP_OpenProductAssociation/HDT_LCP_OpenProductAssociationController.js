({
    doInit : function(component, event, helper) {
        console.log('# controller init #');
        helper.getEnabledUser(component, event, helper);
        //helper.initHelperMethod(component, event, helper);
    }
})