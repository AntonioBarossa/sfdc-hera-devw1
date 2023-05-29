({
    helperMethod : function(component, event, helper) {
        var recordid = component.get('v.recordId');
        console.log('>>>>> recordid ' + recordid);
        component.set('v.recordIdFromAura', recordid);
    }
})
