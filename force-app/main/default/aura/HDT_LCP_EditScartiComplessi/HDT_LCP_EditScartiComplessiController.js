({
    doInit : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        console.log('@@@@Init ' + recordId);
        let action = component.get('c.getInitData');
        action.setParams({ recordId : recordId });
        action.setCallback(this,(response)=>{
            console.log('@@@@In the Action ' + response.getReturnValue());
            if (response.getState() === "SUCCESS"){
                console.log('@@@data ' + response.getReturnValue());
                let data = JSON.parse(response.getReturnValue());
                //Gestione Risottomissione Annullamento
                if (data.annullamento == 'SI'){
                    console.log('@@@Gestione Annullamento');
                    component.set('v.inputRecordId',data.recordId);
                    component.set('v.objectToCancell',data.objectType);
                    helper.openWizardForAnnulment(component,event);
                }else if(data.objectType === "wrts_prcgvr__Activity__c"){
                    console.log('@@@In Activity');
                    component.set('v.activity', data.object);
                    helper.openWizardForActivity(component,event);
                }
                else if (data.objectType === "Case"){
                    console.log('@@@In case');
                    helper.openWizardForCase(component,event);
                }else{
                    console.log('@@@In Order');
                    component.set('v.order', data.object);
                    helper.openWizardForOrder(component,event);
                }
            }else if (response.getState() === "ERROR") {
                console.log('@@@@ERROR ');
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.showAlert(component,errors[0].message,'error','Attenzione!');
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
        
    }
})
