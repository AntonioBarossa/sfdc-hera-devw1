({
    callApexMethod : function(cmp,methodName,params){
		return new Promise($A.getCallback(function(resolve, reject) {
			var action = cmp.get("c."+methodName);
			if (params) action.setParams(params);
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					resolve(response.getReturnValue());
				}
				else
				{
					var error = "";
					var errors = response.getError();
                    console.log(JSON.stringify(errors));
		            if (errors) {
                        if (errors[0]) {
                            if (errors[0].message) {
                                error = errors[0].message;
                            }
                            if (errors[0].pageErrors) {
                                error = errors[0].pageErrors[0].message;
                            }
                        }
	                }
	                reject( error );
				}
			});
			$A.enqueueAction(action);
		}));
	},
    showErrorMessage: function(title,message){
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({            
            'title' : title,
            'type': 'error',
            'message' : message
        });
        showToast.fire();
    },
    showWarningMessage: function(title,message){
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title' : title,
            'type': 'warning',
            'message' : message
        });
        showToast.fire();
    },
    showSuccessMessage: function(title,message){
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title' : title,
            'type': 'success',
            'message' : message
        });
        showToast.fire();
    }
})
