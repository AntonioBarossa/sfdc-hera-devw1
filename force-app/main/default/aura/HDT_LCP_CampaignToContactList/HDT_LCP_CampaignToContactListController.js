({
    doInit : function(component, event, helper) {
        var objName = component.get("v.sObjectName");
        if(objName === undefined){
            objName = '';
        }
        component.set("v.sObjectName", objName);
    },

    onTabClosed : function(component, event, helper) {
        var tabId = event.getParam('tabId'); 
        console.log("Tab closed: " + tabId);
        component.find('hdtCampaignToAccountList').updateCampaignMemberStatus();
    }
})