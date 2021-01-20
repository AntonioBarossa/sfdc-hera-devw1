({
    helperInit : function(component,event,helper) {
        component.set('v.loading', true);
        var pageReference = component.get("v.pageReference");
        component.set("v.orderId", pageReference.state.c__orderId);
        component.set("v.orderParentId", pageReference.state.c__orderParent);

        var action = component.get('c.controllerInit');
        var orderId = component.get('v.orderId');
        action.setParams({
            "orderId" : orderId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.loading', false);
                if (state === "SUCCESS") {                
                    console.log("SUCSSES1",response.getReturnValue());
                    let results = response.getReturnValue();
                    let ord = results.order;
                    let orderItem = results.orderItem;
                    if(orderItem && orderItem.Service_Point__c !== undefined) {
                        component.set('v.orderPod',orderItem.Service_Point__r.ServicePointCode__c);
                    }
                    component.set("v.ordername", ord.Name);
                    component.set("v.orderstatus",ord.Status);
                    if(ord.RecordType){
                    	component.set("v.recordtypeOrder",ord.RecordType.Name);
                    }
                }
                else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
        
    },
    
    setCheckbox : function (component, event, helper){
        var processo = component.get("v.selectedValue");
        if(processo == "Prima Attivazione")
        {
        	component.set('v.precheck','KO');
            component.set('v.compatibilita','OK'); 
            component.set('v.causale',"E' necessario effettuare un subentro");
        }
        else if(processo == 'Subentro')
        {
            component.set('v.precheck','OK');
            component.set('v.compatibilita','OK');
            component.set('v.causale',"");
        }
    },

    saveOp : function (component, event, helper){
        var action = component.get('c.saveOption');
        var orderId = component.get('v.orderId');
        var processo = component.get('v.selectedValue');
        var parentOrderId = component.get('v.parentOrderId');
        console.log("*****Processo: " + processo);
        // action.setParams({
        //     "orderId" : orderId,
        //     "processo" : processo,
        //     "parentOrderId" : parentOrderId
        // });
        // action.setCallback(this, function(response) {
        //     var state = response.getState();
        //         if (state === "SUCCESS") {                
        //              $A.get('e.force:refreshView').fire();
        //         }
        //         else {
        //             console.log("Failed with state: " + state);
        //         }
        //     });
        // $A.enqueueAction(action);
    }
})
