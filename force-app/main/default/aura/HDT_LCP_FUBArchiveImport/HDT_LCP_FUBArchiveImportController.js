({
    onchange: function (component, event, helper) {
        var files = event.getParam("files");
        if (files) {
            component.set("v.fileName", files[0].name);
        }
    },

    readFile: function (component, event, helper) {
        var cmp = component.find("uploadFile");
        var files = cmp.get("v.files");
        if (files) {
            var file = files[0];
            component.set("v.fileName", file.name);
            component.set("v.loading", true);
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var csvNumbers = helper.CSV2JSON(component, csv);
                csvNumbers = csvNumbers.replace('[', '');
                csvNumbers = csvNumbers.replace(']', '');
                csvNumbers = csvNumbers.replaceAll('"', "'");
                console.log('result = ' + csvNumbers);
                //batch execution
                var action = component.get("c.fubArchiveImportBatch");
                action.setParams({ 'recordId': component.get("v.recordId"), 'csvNumbers': csvNumbers });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var res = response.getReturnValue();
                        if (!res) {
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                "title": "Error",
                                "message": "",
                                "type": "error"
                            });
                            resultsToast.fire();
                        }
                    }
                    component.set("v.loading", false);
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    console.log('ReturnValue--> ' + res);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "",
                        "type": "success",
                        "message": "File csv importato correttamente"
                    });
                    toastEvent.fire();
                });
                $A.enqueueAction(action);
            }
            reader.onerror = function (evt) {
                console.log("error reading file" + JSON.stringify(evt));
            }
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "error",
                "message": "File csv non trovato!"
            });
            toastEvent.fire();
        }
    }
})