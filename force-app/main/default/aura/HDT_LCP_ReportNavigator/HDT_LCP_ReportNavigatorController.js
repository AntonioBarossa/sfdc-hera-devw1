({
    onPageReferenceChange : function(cmp, event, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var reportName = myPageRef.state.c__reportName;
        var workspaceAPI = cmp.find("workspace");

        var redirectUrl;
        var isValidReport;

        //try to find report id, otherwise fallback to report home page
        helper.callApexMethod(cmp, "getReportId", {reportName: reportName}).then($A.getCallback(function(reportId) {
            redirectUrl = "/lightning/r/Report/"+reportId+"/view"; //report url
            isValidReport = true;
        }),$A.getCallback(function(error) {
            redirectUrl = "/lightning/o/Report/home"; //report Home page
            isValidReport = false;
        })).then($A.getCallback(function(){

            if (!isValidReport) {
                //report not found, show warning toast
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "warning",
                    "title": "Rapporto non trovato",
                    "message": "Il rapporto "+reportName+" non è disponibile"
                });
                toastEvent.fire();
            }

            //open report tab
            workspaceAPI.openTab({
                url: redirectUrl,
                focus: true
            }).then($A.getCallback(function(){

                //closing temporary tab
                workspaceAPI.getEnclosingTabId().then($A.getCallback(function(currentTabId) {
                    workspaceAPI.closeTab({ tabId: currentTabId })
                })),then($A.getCallback(function() {
                    console.log("Couldnt close tab");
                }));

            }));

        }));
    }
})
