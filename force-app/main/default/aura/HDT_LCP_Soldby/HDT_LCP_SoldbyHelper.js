({
    myAlert : function(component,title,message,type) {
        $A.get("e.force:showToast")
        .setParams({
            "title": title,
            "message": message,
            "type" : type
        })
        .fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    errorHandle: function(component,error){
        let message = "Attenzione! L'operazione non è andata a buon fine";
        if (error){
            console.error(error);
            message = error[0] && error[0].message ? error[0].message : message; 
        } 
        this.myAlert(component,"Error!",message, "error");
    }
})
