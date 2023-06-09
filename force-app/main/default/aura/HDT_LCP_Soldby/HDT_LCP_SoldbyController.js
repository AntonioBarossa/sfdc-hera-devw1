({
    manageSoldBy : function(component, event, helper) {
        var upOrders = component.get("c.updateAllOrder");
        var sale = JSON.parse(event.getParam('detail'));
        upOrders.serParams({sale : sale});
        upOrders.setCallback(this, function(response){
            let state = response.getReturnValue();
            if (state === "SUCCESS"){
                helper.myAlert(component,"Success!","Operazione conclusa con successo","success");
            }else if (state === "ERROR"){
                helper.errorHandle(component,response.getError());
            }
        });
        $A.enqueueAction(upOrders);
    },
    manageError : function(component, event, helper) {
        var message = event.getParam('detail');
        helper.myAlert(component,"Error!",message,"error");
    }
})
