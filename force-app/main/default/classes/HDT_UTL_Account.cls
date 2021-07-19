public with sharing class HDT_UTL_Account {
    @auraEnabled
    public static String checkIsBackoffice(){
        boolean res = false;
        List<UserRole> usRole = [SELECT Id, Name, DeveloperName FROM UserRole WHERE Id IN (SELECT UserRoleId 
        FROM User 
        WHERE Id = :UserInfo.getUserId())];
        String role = usRole[0].Developername;
        return role;
    }

    public static HDT_WS_RicCreBpCaRequest callBpCaSearch(Account a,contact c ){
        HDT_WS_RicCreBpCaRequest req = new HDT_WS_RicCreBpCaRequest();
        String recordType = '';
        if(a.recordtype.developername == 'HDT_RT_Residenziale'){
            recordType = 'Persona fisica';
        } 
        else if(a.recordtype.developername == '	HDT_RT_Business'){
            recordType = 'Organizzazione';
        }
        req.codiceCausale            ='SRC';
        req.numeroSR                 = a.id;
        req.account.tipoAccount      = recordType;
        req.account.categoria        = a.category__c;
        req.account.telefono         = c.MobilePhone;
        req.account.emailCont        = c.email;
        req.account.marcaturaCliente = a.customerMarking__c;
        req.account.codiceFiscale    = c.fiscalCode__c;
        req.account.partitaIva       = a.vatnumber__c;
        return req;
    }
    public static HDT_WS_RicCreBpCaRequest callBpCaCreate(Account a,contact c ){
        HDT_WS_RicCreBpCaRequest req = new HDT_WS_RicCreBpCaRequest();
        String recordType = '';
        if(a.recordtype.developername == 'HDT_RT_Residenziale'){
            recordType = 'Persona fisica';
        } 
        else if(a.recordtype.developername == '	HDT_RT_Business'){
            recordType = 'Organizzazione';
        }
        if(recordType == 'Persona fisica'){
            req.account.alias = a.lastname__c;
            req.account.nome = a.firstName__c;
        }
        req.codiceCausale                   ='CBP';
        req.numeroSR                        = a.id;
        req.account.tipoAccount             = recordType;
        req.account.categoria               = a.category__c;
        req.account.fax                     = a.fax;   
        req.account.telefono                = c.MobilePhone; 
        req.account.marcaturaCliente        = a.customerMarking__c;
        req.account.codiceFiscale           = a.fiscalCode__c;
        req.account.partitaIva              = a.vatnumber__c;
        req.account.indirizzo.comune	    = a.BillingCity;
        req.account.indirizzo.nazione	    = a.BillingCountry;
        req.account.indirizzo.toponimo	    = a.BillingStreetToponym__c;
        req.account.indirizzo.civico	    = a.BillingStreetNumber__c;
        req.account.indirizzo.cap	        = a.BillingPostalCode;
        req.account.indirizzo.provincia	    = a.BillingState;
        req.account.indirizzo.via	        = a.BillingStreetName__c ;
        req.account.partner	                = String.valueOf(a.IsPartner); //TODO chiedre 
        req.account.cellulare	            = a.MobilePhone__c;
        req.account.indirizzo.piano	        = a.BuildingFloor__c;
        req.account.emailCont	            = a.PrimaryEmail__c  ;
        req.account.gruppoIva.partitaIva	= a.VATGroup__c;
        req.account.gruppoIva.dataInizio	= a.VATGroupStartDate__c;
        req.account.gruppoIva.dataFine	    = a.VATGroupEndDate__c;
        req.ordine.pecInvioBolletta	        = c.CertifiedEmail__c;
        return req; 
        
    }
    public static HDT_WS_RicCreBpCaRequest callAmCaCreate(Account a,contact c ){
        HDT_WS_RicCreBpCaRequest req = new HDT_WS_RicCreBpCaRequest();
        String recordType = '';
        if(a.recordtype.developername == 'HDT_RT_Residenziale'){
            recordType = 'Persona fisica';
        } 
        else if(a.recordtype.developername == '	HDT_RT_Business'){
            recordType = 'Organizzazione';
        }
        if(recordType == 'Persona fisica'){
            req.account.alias = a.lastname__c;
            req.account.nome  = a.firstName__c;
        }
        if(recordType == 'Persona fisica'){
            req.account.alias = a.lastname__c;
            req.account.nome  = a.firstName__c;
        }
        req.codiceCausale                                       ='AMM';
        req.numeroSR	                                        = a.id;
        req.ordine.destinatarioDivergente.nome	                = a.FirstName__c;
        req.ordine.destinatarioDivergente.indirizzo.civico	    = a.BillingStreetNumber__c;
        req.ordine.destinatarioDivergente.indirizzo.via	        = a.BillingStreetName__c;
        req.ordine.destinatarioDivergente.codiceFiscale	        = a.FiscalCode__c;
        req.ordine.destinatarioDivergente.indirizzo.nazione     = a.BillingCountry;
        req.ordine.destinatarioDivergente.email	                = c.email;
        req.ordine.destinatarioDivergente.partitaIva	        = a.VATNumber__c;
        req.ordine.destinatarioDivergente.indirizzo.provincia	= a.BillingState;
        req.ordine.destinatarioDivergente.telefono	            = c.phone;
        req.ordine.destinatarioDivergente.cognome	            = a.LastName__c;
        req.account.partner	                                    = String.valueOf(a.IsPartner);
        req.account.cellulare	                                = a.MobilePhone__c;
        req.ordine.emailInvioBolletta	                        = c.email;
        req.account.fax	                                        = a.fax;
        req.account.telefono	                                = c.phone;
        req.account.marcaturaCliente	                        = a.customerMarking__c;
        req.account.nome	                                    = a.FirstName__c;
        req.account.codiceFiscale	                            = a.FiscalCode__c;
        req.account.partitaIva	                                = a.VATNumber__c;
        req.account.indirizzo.comune	                        = a.BillingCity;
        req.account.indirizzo.nazione	                        = a.BillingCountry;
        req.account.indirizzo.toponimo	                        = a.BillingStreetToponym__c;
        req.account.indirizzo.piano	                            = a.BuildingFloor__c;
        req.account.indirizzo.civico	                        = a.BillingStreetNumber__c;
        req.account.indirizzo.cap	                            = a.BillingPostalCode;
        req.account.indirizzo.provincia	                        = a.BillingState;
        req.account.indirizzo.via	                            = a.BillingStreetName__c;
        req.account.emailCont	                                = a.PrimaryEmail__c;
        req.account.gruppoIva.partitaIva	                    = a.VATGroup__c;
        req.account.gruppoIva.dataInizio	                    = a.VATGroupStartDate__c;
        req.account.gruppoIva.dataFine	                        = a.VATGroupEndDate__c;
        req.ordine.pecInvioBolletta                             = c.CertifiedEmail__c;
        return req; 
    }
    
  
    public static void makeRequest( Account acc,Contact cont){
        HDT_WS_RicCreBpCaRequest   req = callBpCaSearch(acc,cont);
        HDT_WS_RichCreBpCaResponse res = HDT_WS_RicCreBpCaInvoker.invokeCall(req);
        analizeResponse(res,acc,cont);
    }
    
    public static Account massiveRequest( Account acc,Contact cont){
        HDT_WS_RicCreBpCaRequest   req = callBpCaSearch(acc,cont);
        HDT_WS_RichCreBpCaResponse res = HDT_WS_RicCreBpCaInvoker.invokeCall(req);
        Account ac = analizeMassiveResponse(res,acc,cont);
        return ac;
    }
    public static void analizeResponse(HDT_WS_RichCreBpCaResponse res,account acc,Contact cont ){
        HDT_WS_RicCreBpCaRequest   req;
        HDT_WS_RichCreBpCaResponse resCreate;
        if ('success'.equalsIgnoreCase(res.status)) {
            if (!'Errore'.equalsIgnoreCase(res.data.tipoAttivita)) {
                acc.Code__c = res.data.codiceBP;
                update acc;
            }
            else if('Grandi Condomini'.equalsIgnoreCase(acc.Category__c) || 'Piccoli Condomini'.equalsIgnoreCase(acc.Category__c)) {
                // amministratore di condominio viene identificato  dalla category 
                req = callAmCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert amministratore
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.Code__c = resCreate.data.codiceBP; 
                    update acc;
                } // TODO gestire l'errore 
            }
            else {
                req=callBpCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.Code__c = resCreate.data.codiceBP; 
                    update acc;
                } // TODO gestire l'errore 
            }
        } // TODO else per la gestione dell'errore
        //return acc;
    }
    public static Account analizeMassiveResponse(HDT_WS_RichCreBpCaResponse res,account acc,Contact cont ){
        HDT_WS_RicCreBpCaRequest   req;
        HDT_WS_RichCreBpCaResponse resCreate;
        if ('success'.equalsIgnoreCase(res.status)) {
            if (!'Errore'.equalsIgnoreCase(res.data.tipoAttivita)) {
                acc.Code__c = res.data.codiceBP;
               // update acc;
            }
            else if('Grandi Condomini'.equalsIgnoreCase(acc.Category__c) || 'Piccoli Condomini'.equalsIgnoreCase(acc.Category__c)) {
                // amministratore di condominio viene identificato  dalla category 
                req = callAmCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert amministratore
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.Code__c = resCreate.data.codiceBP; 
                 //   update acc;
                } // TODO gestire l'errore 
            }
            else {
                req=callBpCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.Code__c = resCreate.data.codiceBP; 
                   // update acc;
                } // TODO gestire l'errore 
            }
        } // TODO else per la gestione dell'errore
        return acc;
    }
}

