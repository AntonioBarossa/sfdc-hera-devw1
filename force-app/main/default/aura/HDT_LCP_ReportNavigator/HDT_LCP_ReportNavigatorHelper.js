({
    callApexMethod : function(cmp, methodName, params){
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
		            if (errors) {
	                    if (errors[0] && errors[0].message) {
	                        error = errors[0].message;
	                    }
	                }
	                reject( error );
				}
			});
			$A.enqueueAction(action);
		}));
	}
})
