({
    doInit: function(component, event, helper) {
        console.log(component.get("v.recordId"));
        var action = component.get("c.isValidPhase");
        action.setParams({'recordId': component.get("v.recordId")});
        action.setCallback(this,function(response){
        	var state = response.getState();
            console.log("first step");
            if (state === "SUCCESS") {
                //component.set("v.formValid",response.getReturnValue());//true);//response.getReturnValue());
            	var res = response.getReturnValue();
                if(!res){
                	var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "Validazione Non richiesta o Già Effettuata",
                        "type" : "error"
                    });
                    resultsToast.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                	dismissActionPanel.fire();
                }
                
                // Close the action panel
            }
            component.set("v.HideSpinner",false);
        });
        $A.enqueueAction(action);

        //ottenimento accountId dell'order - INIZIO 
        var action2 = component.get("c.getOrderAccountId");
        
        action2.setParams({
            'orderRecordId': component.get("v.recordId")
        });
        
        action2.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.accountId", response.getReturnValue());        
                console.log('AccountId : '+ component.get("v.accountId"));        
            }
            else{
                var errors = response.getError();  
                console.log('Action fallita! '+JSON.stringify(errors));   
                component.set("v.ErrorType",JSON.stringify(errors));
                console.log(component.get("v.ErrorType"));
            }
        });
        $A.enqueueAction(action2);
        //ottenimento accountId dell'order - FINE
    },

    handleOnload: function(component, event, helper) {
        let order = {};
        // let CILegalRepresentative = component.find('CILegalRepresentative').get('v.value');
        // if (CILegalRepresentative == null) {
        //     component.set('v.CILegalRepresentative', false);
        // }
        //EVERIS PER VOLTURA
        let CIAccoutn = component.find('CIAccoutn').get('v.value');
         if (CIAccoutn == null) {
             component.set('v.CIAccoutn', false);
         }

        let QuickQuote = component.find('QuickQuote').get('v.value');
        if (QuickQuote == null) {
            component.set('v.QuickQuote', false);
        }
        
        let ChamberCommerceRegistration = component.find('ChamberCommerceRegistration').get('v.value');
        if (ChamberCommerceRegistration == null) {
            component.set('v.ChamberCommerceRegistration', false);
        }

        let Instance326 = component.find('Instance326').get('v.value');
        if (Instance326 == null) {
            component.set('v.Instance326', false);
        }

        let DocumentLow80 = component.find('DocumentLow80').get('v.value');
        if (DocumentLow80 == null) {
            component.set('v.DocumentLow80', false);
        }
        
        let AutorizationVolturaThirdTrader = component.find('AutorizationVolturaThirdTrader').get('v.value');
        if (AutorizationVolturaThirdTrader == null) {
            component.set('v.AutorizationVolturaThirdTrader', false);
        }

        let DocumentPackage = component.find('DocumentPackage').get('v.value');
        if (DocumentPackage == null) {
            component.set('v.DocumentPackage', false);
        }

        if (QuickQuote || ChamberCommerceRegistration || Instance326 || DocumentLow80 || AutorizationVolturaThirdTrader || DocumentPackage /*Everis*/|| CIAccoutn/*Everis*/) {
            component.set('v.formValid', true);
        } else {
            component.set('v.formValid', false);
        }

       /* order.CILegalRepresentative__c = CILegalRepresentative;
        order.CIAccoutn__c = CIAccoutn;
        order.QuickQuote__c = QuickQuote;
        order.ChamberCommerceRegistration__c = ChamberCommerceRegistration;
        order.Instance326__c = Instance326;
        order.DocumentLow80__c = DocumentLow80;
        order.AutorizationVolturaThirdTrader__c = AutorizationVolturaThirdTrader;
        
        component.set("v.ordOBJ",order);*/
        // console.log(CILegalRepresentative);
        // console.log(CIAccoutn);
        console.log('QuickQuote: ' + QuickQuote);
        console.log('ChamberCommerceRegistration: ' + ChamberCommerceRegistration);
        console.log('Instance326: ' + Instance326);
        console.log('DocumentLow80: ' + DocumentLow80);
        console.log('AutorizationVolturaThirdTrader: ' + AutorizationVolturaThirdTrader);
        console.log('DocumentPackage: ' + DocumentPackage);
    },

    handleSubmit: function(component, event, helper) {
        let button = event.getSource();
        button.set('v.disabled',true);
        //component.find("editForm").submit();
        let order = {};
        // let CILegalRepresentative = component.find('CILegalRepresentative').get('v.value');
        //Everis
        let CIAccoutn = component.find('CIAccoutn').get('v.value');
        //Everis
        let QuickQuote = component.find('QuickQuote').get('v.value');
        let ChamberCommerceRegistration = component.find('ChamberCommerceRegistration').get('v.value');
        let Instance326 = component.find('Instance326').get('v.value');
        let DocumentLow80 = component.find('DocumentLow80').get('v.value');
        let AutorizationVolturaThirdTrader = component.find('AutorizationVolturaThirdTrader').get('v.value');
        let DocumentPackage = component.find('DocumentPackage').get('v.value');

        let checkArray = [CIAccoutn, QuickQuote, ChamberCommerceRegistration, Instance326, DocumentLow80, AutorizationVolturaThirdTrader, DocumentPackage];

        console.log('checkArray: ' + checkArray);
        console.log('checkArray results : ' + checkArray.includes('Non Validato'));

        if (checkArray.includes('Non Validato')) {
            component.set("v.notValid", true);
        } else {
            // order.CILegalRepresentative__c = CILegalRepresentative;
            order.CIAccoutn__c = CIAccoutn;
            order.QuickQuote__c = QuickQuote;
            order.ChamberCommerceRegistration__c = ChamberCommerceRegistration;
            order.Instance326__c = Instance326;
            order.DocumentLow80__c = DocumentLow80;
            order.AutorizationVolturaThirdTrader__c = AutorizationVolturaThirdTrader;
            order.DocumentPackage__c = DocumentPackage;
            order.Id = component.get("v.recordId");
            component.set("v.ordOBJ",order);
            var action = component.get("c.saveValidation");
            action.setParams({'ord': component.get("v.ordOBJ")});
            action.setCallback(this,function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("HOLA");
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();  
                }
                button.set('v.disabled',false); 
            });
            $A.enqueueAction(action);          
            //$A.get("e.force:closeQuickAction").fire();
        }
    },

    handleCancel: function(component, event, helper) {
        //close the modal
        $A.get("e.force:closeQuickAction").fire();
    },

    handleDialogResponse: function(component, event, helper){
        if(event.getParam('status') == true){
            console.log(component.get("v.recordId"));
            var action = component.get("c.cancelOrder");
            action.setParams({'recordId': component.get("v.recordId")});
            action.setCallback(this,function(response){
                var state = response.getState();
                console.log("first step");
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    component.set("v.notValid", false);
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();  
                }
                component.set("v.HideSpinner",false);
            });
            $A.enqueueAction(action);  
        } else {
            component.set("v.notValid", false);
        }
    },

    ConsensoMarketingInserito_onChange: function(component, event, helper) {

       if(component.find('ConsensoMarketingInserito').get('v.value') == 'No')
       {
            console.log("No");
            component.set("v.ConsensoMarketingInserito_value", false);
       }
       else if(component.find('ConsensoMarketingInserito').get('v.value') == 'Si')
       {
            console.log("Si");
            component.set("v.ConsensoMarketingInserito_value", true);

       }
    },

    InvokeCase: function(component, event, helper) {
        console.log('SONO ENTRATO NELL InvokeCase');
        console.log('punto 1');
        var myPageRef = component.get("v.pageReference");
        console.log('punto 2');
        var flowName = "HDT_FL_PostSalesMasterDispatch";
        console.log('punto 3');
        var processType = "Modifica Privacy";
        console.log('punto 4');
        var recordTypeName = "HDT_RT_GestionePrivacy";
        console.log('punto 5');

        // id dell'Order
        var orderId = component.get("v.recordId");
        var accountId = component.get("v.accountId");

        console.log('punto 6');


        console.log('# flowName -> '                + flowName);
        console.log('# processType -> '             + processType);
        console.log('# recordTypeName -> '          + recordTypeName);

        console.log('# orderId -> '                 + orderId);
                
        var workspaceAPI = component.find("workspace");
        console.log('punto 7');

        var tabToClose;
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log('# TabId To Close: ' + tabId);
            tabToClose = tabId;
        }).catch(function(error) {
            console.log(error);
        });
        console.log('punto 8');

        var parentId;
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log('----------');
            response.forEach((element) => {
                if(element.pageReference.type === 'standard__recordPage'){
                    
                    if(element.pageReference.attributes.recordId === orderId){
                        parentId = element.tabId;
                    }
                }
            });
            console.log('----------');
            console.log('# parentId -> ' + parentId);

            workspaceAPI.openSubtab({
                parentTabId: parentId,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__HDT_LCP_OpenAuraCmp'
                    },
                    state: {
                        c__accid: accountId,
                        c__flowName: flowName,
                        c__processType: processType,
                        c__recordTypeName: recordTypeName,
                        c__orderId: orderId
                    }
                },
                focus: true
            }).then(function(newTabId) {
                console.log('# wizard tab id: ' + newTabId);
                workspaceAPI.setTabLabel({ tabId: newTabId, label: 'Wizard' });
                workspaceAPI.setTabIcon({ tabId: newTabId, icon: 'custom:custom83' });

                workspaceAPI.closeTab({ tabId: tabToClose }).then(function(success) {
                    if (success) {
                        workspaceAPI.focusTab({tabId: newTabId});
                    }
                });
            });

        }).catch(function(error) {
            console.log(error);
        });

        console.log('punto 9');

    }
})