({
    getChannel : function(component, event, helper) {
        var getChannel = component.get("c.getSaleChannel");

        getChannel.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS"){
                let channel = response.getReturnValue();
                if (channel){
                    component.set('v.channel',channel);
                    component.set('v.showTable',true);
                    return;
                }
                helper.errorHandle(component,channel);
            }else if (state === "ERROR"){
                helper.errorHandle(component,response.getError());
            }
        });
        $A.enqueueAction(getChannel);
    },
    manageSoldBy : function(component, event, helper) {
        var upOrders = component.get("c.updateAllOrder");

        upOrders.setCallback(this, function(response){
            let state = response.getReturnValue();
            if (state === "SUCCESS"){
                helper.myAlert(component,"Success!","Operazione conclusa con successo","success");
            }else if (state === "ERROR"){
                helper.errorHandle(component,response.getError());
            }
            toastEvent.fire();
        });
        $A.enqueueAction(upOrders);
    }
})
