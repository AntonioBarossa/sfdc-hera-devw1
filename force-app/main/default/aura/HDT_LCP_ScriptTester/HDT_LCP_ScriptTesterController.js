({
    doInit : function(cmp, event, helper) {
        var order = {
            "fields": {
              "CreatedBy": {
                "value": {
                  "fields": {
                    "LoginChannel__c": {
                      "value": "Teleselling"
                    }
                  }
                }
              },
              "SignatureMethod__c": {
                "value": "Vocal Order"
              },
              "Status": {
                "value": "In Lavorazione"
              }
            }
        };
        cmp.set("v.order", order);

        helper.callApexMethod(cmp, "getScripts").then($A.getCallback(function(scripts){
            cmp.set("v.scripts", scripts);
        }));
    },
    openScript : function(cmp, event, helper) {
        var scriptId = event.getSource().get("v.value");
        window.open("/"+scriptId);
    }
})
