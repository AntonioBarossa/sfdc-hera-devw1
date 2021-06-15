({
    doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        console.log(component.get("v.sObjectName"));
    },

    onTabClosed : function(component, event, helper) {
        var tabId = event.getParam('tabId'); 
        console.log("Tab closed: " + tabId);
        component.find('hdtCampaignToAccountList').updateCampaignMemberStatus();
    }
})