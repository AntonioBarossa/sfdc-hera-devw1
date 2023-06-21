({
    /*  MODIFICA 25/03/2022 marco.arci@webresult.it - Commentate logiche onBlur perchè motivo di errore con logiche superflue"
    controlCodiceCliente : function(cmp,event,helper){          
        var searchKey=  cmp.get('v.searchKey');
        if(searchKey=="" || searchKey==undefined){
            this.message="Il valore inserito non è corretto";
            cmp.set('v.searchDisabled',true);
        }else if(searchKey.length>7){
            cmp.set('v.searchDisabled',false);
        }else{
            cmp.set('v.searchDisabled',false);
        }
    },
    controlfiscalcode: function(cmp,event){
        var searchKey=  cmp.get('v.searchKey');
        if(searchKey.length<11||searchKey.length>16){
            cmp.set('v.message',"Il valore inserito non è un codice fiscale");
            var inputText = cmp.find('inputTxtId');
            var validity =inputText.get("v.validity");
            inputText.set('v.validity', {valid:false, badInput :true});
            cmp.set('v.searchDisabled',true);  
        }else{
            cmp.set('v.searchDisabled',false);
        }

    },
    controlpartitaiva: function(cmp,event,helper){
        var searchKey=  cmp.get('v.searchKey');
        if(searchKey.length<11||searchKey.length>16){
            this.message="La lunghezza del codice inserito non è valido (P.IVA: 11 cifre)";
            cmp.set('v.searchDisabled',true); 
            this.showNotification();
        }else{
            cmp.set('v.searchDisabled',false);
        }
    },
    */
    startSpinner: function(component){       
        if(component.find("spinner"))
        component.find("spinner").start();
    },
    stopSpinner: function(component){        
        component.find("spinner").stop();
        //component.set('v.disableAssistiveSpinner',false);     //MODIFICA 18/03/2022 marco.arci@webresult.it collaudi UAT - riga commentata - variabile non presente
    },
    retrieveData : function(cmp, event,helper){
        this.startSpinner(cmp);
        let action = cmp.get("c.getExternalCustomer");
        action.setParams({
            "searchKey"     : cmp.get('v.searchKey'),
            "sortBy"        : cmp.get('v.sortedBy'),
            "sortDirection" : cmp.get('v.sortedDirection'),
            "filterby"      : cmp.get('v.value'),
            "silos"         : cmp.get('v.silosValue')
        }); 
        action.setCallback(this, function(response) {
            this.stopSpinner(cmp);
            let rows=[];
            var state = response.getState();
            if (cmp.isValid() && state == "SUCCESS") {
                if(!response.getReturnValue()){
                    this.message="Il Silos selezionato non è ammesso per la tua utenza!";
                    this.showNotification();
                    return;
                }
                var records =response.getReturnValue();
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                console.log('AAAA');                
                cmp.set('v.data',records);
                if(records.length == 0){
                    cmp.set('v.showTable',false)
                    cmp.set('v.noResults',true)
                }
                else{
                    cmp.set('v.showTable',true)
                    cmp.set('v.noResults',false)
                }
                console.log('Data')
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    showNotification : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
           // "title": "Success!",
            "message": this.message,
            "type": "error"
        });
        toastEvent.fire();
    }
})