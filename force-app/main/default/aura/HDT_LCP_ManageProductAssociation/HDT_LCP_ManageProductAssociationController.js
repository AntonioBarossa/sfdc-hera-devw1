({
	doInit : function(component, event, helper) {
        var recordid = component.get("v.pageReference").state.c__recordId;

        //dinamically create component
        $A.createComponent(
            'c:hdtManageProductAssociation', {productid: recordid},
            function(lwcCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(lwcCmp);
                    component.set("v.body", body);
                    component.set('v.loaded', true);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                else if (status === "ERROR") {
                    console.error("Error: " + errorMessage);
                }
            }
          );
    

	},

    goback : function(component, event, helper) {
        console.log('>>>>>>>>>>> page change -> refresh page');
        $A.get('e.force:refreshView').fire();
    },

    update : function (component, event, helper) {
        console.log('>>>>>>>>>>> page change -> delete component');
        component.set("v.body", []);
    }

})