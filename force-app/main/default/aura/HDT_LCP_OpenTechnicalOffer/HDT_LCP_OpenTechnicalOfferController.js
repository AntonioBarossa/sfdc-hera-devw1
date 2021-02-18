({
	doInit : function(component, event, helper) {
		/*console.log('# ----- #');
        var i = component.get('v.recordId');
        console.log('# recId -> ' + i);
        component.set('v.recIdLWC', i);*/
        var pageReference = component.get("v.pageReference");
        var recordid = pageReference.state.c__recordId;
        var technicalOfferId = pageReference.state.c__technicalOfferId;

        component.set('v.recordId', recordid);
        component.set('v.technicalOfferId', technicalOfferId);

        //var workspaceAPI = component.find("workspace");
        //workspaceAPI.getFocusedTabInfo().then(function(response) {
        //    var focusedTabId = response.tabId;
        //    //workspaceAPI.setTabLabel({
        //    //    tabId: focusedTabId,
        //    //    label: "Configurazione"
        //    //});
        //    workspaceAPI.setTabIcon({
        //                tabId: focusedTabId,
        //                icon: "utility:products",
        //                iconAlt: "Edit Tab"
        //    }).catch(function(error) {
        //        console.log('# ERROR - ' + error);
        //    });
        //})
        //.catch(function(error) {
        //    console.log('# ERROR - ' + error);
        //});

	},
    
    goback : function(component, event, helper) {
        console.log('# close this aura #');
        var prodId = event.getParam('prodId');
        console.log('#  # ' + prodId);
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });

    }

})