({
    helperInit : function(component,event,helper) {
	
		var action = component.get('c.controllerInit');
        var orderId = component.get('v.orderId');
        action.setParams({
            "orderId" : orderId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {                
                    console.log("SUCSSES1",response.getReturnValue());
                    let results = response.getReturnValue();
                    let ord = results.order;
                    let orderItem = results.orderItem;
                    if(orderItem && ordItem.Service_Point__c !== undefined) {
                        component.set('v.orderPod',ordItem.Service_Point__c !== undefined);
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

    // saveOp : function (component, event, helper){
    //     var action = component.get('c.saveOption');
    //     var orderId = component.get('v.orderId');
    //     var processo = component.get('v.selectedValue');
    //     var ordineVendita = component.get('v.ordineVendita');
    //     console.log("***** :" + processo);
    //     action.setParams({
    //         "orderId" : orderId,
    //         "processo" : processo,
    //         "ordineVendita" : ordineVendita
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //             if (state === "SUCCESS") {                
    //                 component.set("v.openModale",false);
    //                  $A.get('e.force:refreshView').fire();
    //                 // component.set("v.step", 2) 
    //             }
    //             else {
    //                 console.log("Failed with state: " + state);
    //             }
    //         });
    //         $A.enqueueAction(action);
    // }
})
