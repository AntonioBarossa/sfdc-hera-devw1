({
    doInit: function(component) {       
        console.log('New component')
        component.set("v.forcedvaluesAA", [{ 'label': 'Codice Fiscale', 'value': 'Codice Fiscale' },{ 'label': 'Partita Iva', 'value': 'Partita Iva' },{'label': 'Codice Cliente', 'value': 'Codice Cliente' }]);
        component.set("v.columns", [{
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
        }else{
            component.set('v.picklistDisabled',true);
        }
    },
    handleKeyChange: function(cmp,event,helper) {
        var searchKey= cmp.get('v.searchKey');    
        var value =  cmp.get('v.value');
        if(searchKey!=""){
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