({
    doInit: function(component) {       
        console.log('New component')
        component.set("v.forcedvaluesAA", [{ 'label': 'Codice Fiscale', 'value': 'Codice Fiscale' },{ 'label': 'Partita Iva', 'value': 'Partita Iva' },{'label': 'Codice Cliente', 'value': 'Codice Cliente' }]);
        
        //START 25/10/2022 costanzo.lomele@webresults.it Wave 2
        component.set("v.silosOptions", [{ 'label': 'none', 'value': 'none' },
        {'label': 'AAA-EBT', 'value': 'AAA-EBT' },
        {'label': 'HERA COMM', 'value': 'HERA COMM' },
        {'label': 'MMS', 'value': 'MMS' },
        {'label': 'Reseller', 'value': 'Reseller' }]);
        //END 25/10/2022 costanzo.lomele@webresults.it Wave 2

        component.set("v.columns", [
        //START 25/10/2022 costanzo.lomele@webresults.it Wave 2
        {
            label: 'Silos',
            fieldName: 'silos',
            sortable: true
        },
        //END 25/10/2022 costanzo.lomele@webresults.it Wave 2
        {
            label: 'Cognome / Rag. Sociale',
            fieldName: 'linkName',
            type: 'url',        
            sortable: true,
            typeAttributes: {label: { fieldName: 'Nome' }, target: '_self'}
        },
        {
            label: 'Nome',
            fieldName: 'NomeProprio',
            sortable: true
        },
        {
            label: 'Codice fiscale',
            fieldName: 'CodiceFiscale',
            sortable: true
        },
        {
            label: 'Partita Iva',
            fieldName: 'IVA',
            sortable: true
        },
        {
            label: 'Codice Cliente',
            fieldName: 'CodiceCliente',
            sortable: true
        }]);
        component.set("v.buttonButtonSingleDisabled", true);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Ricerca Archivio"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:search",
                iconAlt: "Search"
            });
        })
    },
    handleInputChange: function(component,event){        
        var value= component.get('v.value');        
        if(value){
            component.set('v.picklistDisabled',false);
            //START>>> MODIFICA 25/03/2022 marco.arci@webresult.it - per controllare i valori già inseriti al cambiamento della chiave 
            var checkValues = component.get('c.handleKeyChange');
            $A.enqueueAction(checkValues);
            //END>>> MODIFICA 25/03/2022 marco.arci@webresult.it - per controllare i valori già inseriti al cambiamento della chiave
        }else{
            component.set('v.picklistDisabled',true);
        }
    },
    handleKeyChange: function(cmp,event,helper) {
        var searchKey= cmp.get('v.searchKey');    
        var value =  cmp.get('v.value');
        if(searchKey!="" && searchKey!=undefined){  // MODIFICA 25/03/2022 marco.arci@webresult.it - Aggiunta filtro undefined per evitare errori
            if(value=="Codice Fiscale"){
                if(searchKey.length>=11 && searchKey.length<=16){cmp.set('v.searchDisabled',false); }
                else{cmp.set('v.searchDisabled',true);}
            }else if(value=="Partita Iva"){
                if(searchKey.length>=11 && searchKey.length<=16){cmp.set('v.searchDisabled',false); }
                else{cmp.set('v.searchDisabled',true);}
            }else if(value=="Codice Cliente"){
                if(searchKey.length>=7 ){cmp.set('v.searchDisabled',false); }
                else{cmp.set('v.searchDisabled',true);}
            }
        }else{
            cmp.set('v.searchDisabled',true); 
        }
    },
    /*      MODIFICA 25/03/2022 marco.arci@webresult.it - Commentata logica onBlur perchè motivo di errore con logiche superflue"
    handleKeyBlur: function(cmp,event,helper) {
        var searchKey= cmp.get('v.searchKey');    
        var value =  cmp.get('v.value');
        if(searchKey!=""){   
            if(value=="Codice Fiscale"){
                helper.controlfiscalcode(cmp,event);      
            }else if(value=="Partita Iva"){
                helper.controlpartitaiva(cmp,event,helper);
            }else if(value=="Codice Cliente"){
                helper.controlCodiceCliente(cmp,event,helper);
            }
        }else{
            cmp.set('v.searchDisabled',true); 
        }
    },
    */
    handleSearch: function(cmp,event,helper){        
        helper.retrieveData(cmp,event,helper)  ;  
    },
    getSelectedRows: function(cmp,helper,event){
        const result = event.detail.selectedrow;
        this.accountId = result.id;
        this.data = [];
        getExternalContact({searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection'})
            .then(result => {
                if(result != null && result.length >0){
                    this.showContactsTable = true;
                    this.data = result; 
                }
                else{
                    this.openToast('alert', noAccountFound);

                }
            })
    }

    
})