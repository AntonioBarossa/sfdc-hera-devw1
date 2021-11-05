({
    myAction : function(component, event, helper) {

    },
    //HRAWRM-915 21/10/2021
    closeQA : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}//HRAWRM-915 21/10/2021
})
