/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 16/07/2021
* @description HDT_UTL_Note
* @history Lorenzo – 16/07/2021 – created class
*/
public with sharing class HDT_UTL_Account {
    private static Id accRecordTypeIdResidenziale = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
    private static Id accRecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();

    public static void handleFiscalCodeUppercase(List<Account> accountList){
        for(Account singleAccount : accountList){
            String fiscalCode = singleAccount.FiscalCode__c;
            if(String.isNotBlank(fiscalCode) && fiscalCode.isAlphanumeric()){
                singleAccount.FiscalCode__c = fiscalCode.toUpperCase();
            }
        }
    }

    @AuraEnabled
    public static String checkIsBackoffice(){
       // boolean res = false;
        List<UserRole> usRole = [SELECT Id, Name, DeveloperName FROM UserRole WHERE Id IN (SELECT UserRoleId 
        FROM User 
        WHERE Id = :UserInfo.getUserId()) WITH SECURITY_ENFORCED];
        String role = usRole[0].Developername;
        return role;
    }

    public static HDT_WS_RicCreBpCaRequest callBpCaSearch(Account a,contact c ){
        HDT_WS_RicCreBpCaRequest req = new HDT_WS_RicCreBpCaRequest();
        //Id accRecordTypeIdResidenziale = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
       // Id accRecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();

        String recordType = '';
        if(a.recordtypeId == accRecordTypeIdResidenziale){
            recordType = 'Persona fisica';
        } 
        else if(a.recordtypeId == accRecordTypeIdBusiness){
            recordType = 'Organizzazione';
        }
        /**@frpanico 13/01/2022
         * aggiunta modifica per 
         * ricerca correttamente clienti business
         */
        String fiscalCode = String.isNotBlank(a.FiscalCode__c) && a.FiscalCode__c.isAlphanumeric()?a.FiscalCode__c.toUpperCase():a.FiscalCode__c;
        req.codiceCausale            ='SRC';
        req.numeroSR                 = a.id;
        req.account.tipoAccount      = recordType;
        req.account.categoria        = a.category__c;
        req.account.telefono         = c.MobilePhone;
        req.account.emailCont        = c.email;
        req.account.marcaturaCliente = a.customerMarking__c;
        req.account.codiceFiscale    = a.FiscalCode__c != null ? fiscalCode : a.vatNumber__c;
        // req.account.codiceFiscale    = recordType == 'Organizzazione' 
        //                                 ? a.vatnumber__c != null
        //                                     ? a.vatnumber__c : a.FiscalCode__c
        //                                 : a.FiscalCode__c;
        req.account.partitaIva       = '';
        return req;
    }
    public static HDT_WS_RicCreBpCaRequest callBpCaCreate(Account a,contact c ){
        HDT_WS_RicCreBpCaRequest req = new HDT_WS_RicCreBpCaRequest();
        String recordType = '';

       // Id accRecordTypeIdResidenziale = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
       // Id accRecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
        
       //Start HRAWRM-437 02/09/2021
        req.account.nome=a.Name;
        req.account.alias=a.Name;
        //End HRAWRM-437 02/09/2021
        if(a.recordtypeId == accRecordTypeIdResidenziale){
            recordType = 'Persona fisica';
        } 
        else if(a.recordtypeId == accRecordTypeIdBusiness){
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
        req.account.indirizzo.nazione	    = getStateIso(a.BillingCountry);
        // req.account.indirizzo.toponimo	    = a.BillingStreetToponym__c;
        req.account.indirizzo.civico	    = a.BillingStreetNumber__c;
        req.account.indirizzo.cap	        = a.BillingPostalCode;
        req.account.indirizzo.provincia	    = a.BillingState;
        req.account.indirizzo.via	        = a.BillingStreetName__c ;
        req.account.partner	                = a.CustomerCode__c;
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
        //Id accRecordTypeIdResidenziale = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
        //Id accRecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();

        if(a.recordtypeId == accRecordTypeIdResidenziale){
            recordType = 'Persona fisica';
        } 
        else if(a.recordtypeId == accRecordTypeIdBusiness){
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
        req.ordine.destinatarioDivergente.codiceFiscale	        = a.FiscalCode__c;

        req.ordine.destinatarioDivergente.indirizzo.civico	    = a.BillingStreetNumber__c;
        req.ordine.destinatarioDivergente.indirizzo.via	        = a.BillingStreetName__c;
        req.ordine.destinatarioDivergente.indirizzo.nazione     = getStateIso(a.BillingCountry);
        req.ordine.destinatarioDivergente.indirizzo.provincia	= a.BillingState;
        req.ordine.destinatarioDivergente.indirizzo.comune      = a.BillingCity;
        req.ordine.destinatarioDivergente.indirizzo.cap         = a.BillingPostalCode;

        req.ordine.destinatarioDivergente.email	                = c.email;
        req.ordine.destinatarioDivergente.partitaIva	        = a.VATNumber__c;
        req.ordine.destinatarioDivergente.telefono	            = c.phone;
        req.ordine.destinatarioDivergente.cognome	            = a.LastName__c;
        req.account.partner	                                    = a.CustomerCode__c;
        req.account.cellulare	                                = a.MobilePhone__c;
        req.ordine.emailInvioBolletta	                        = c.email;
        req.account.fax	                                        = a.fax;
        req.account.telefono	                                = c.phone;
        req.account.marcaturaCliente	                        = a.customerMarking__c;
        req.account.nome	                                    = a.FirstName__c;
        req.account.codiceFiscale	                            = a.FiscalCode__c;
        req.account.partitaIva	                                = a.VATNumber__c;
        req.account.indirizzo.comune	                        = a.BillingCity;
        req.account.indirizzo.nazione	                        = getStateIso(a.BillingCountry);
        // req.account.indirizzo.toponimo	                        = a.BillingStreetToponym__c;
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
        //Nuova Versione
        string accountType = Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).getDeveloperName();
        List<SiebelCustomer__x> siebelCustomer = new List<SiebelCustomer__x>();
        List<SObject> sobjToUpdate = new List<SObject>();
        /* Setup query filters */
        String category = acc.Category__c;
        String vatNumber = acc.VATNumber__c;
        String fiscalCode = acc.FiscalCode__c;
        Boolean archive = false;
        try{            
            Contact contRelation = new Contact();

            /* Query account archive */
            String query = 'SELECT Id,OU_NUM__c, X_MARCATURA_CLIENTE__c FROM SiebelCustomer__x WHERE OU_TYPE_CD__c = :category';
            if(acc.FiscalCode__c != null && acc.FiscalCode__c != '')
            {
                query += ' AND TAX_IDEN_NUM__c = :fiscalCode';
            }
            if(acc.VATNumber__c != null && acc.VATNumber__c != '')
            {
                query += ' AND VAT_REGN_NUM__c = :vatNumber';
            }
            query += ' WITH SECURITY_ENFORCED';

            siebelCustomer = Database.query(query);
            /* If query returns results update account */
            if(!siebelCustomer.isEmpty()){
                archive = true;
                acc.CustomerCode__c = siebelCustomer[0].OU_NUM__c;
                acc.CustomerMarking__c = siebelCustomer[0].X_MARCATURA_CLIENTE__c;
                sobjToUpdate.add(acc);
            }
            /* If query does not return results call BpCaSearch */
            else{
                HDT_WS_RicCreBpCaRequest   req = callBpCaSearch(acc,cont);
                HDT_WS_RichCreBpCaResponse res = HDT_WS_RicCreBpCaInvoker.invokeCall(req);
                if ('success'.equalsIgnoreCase(res.status) && String.isNotBlank(res.data.codiceBP)) {
                    acc.CustomerCode__c = res.data.codiceBP;
                    sobjToUpdate.add(acc);
                }       
            }
            contRelation = registerAmmCondominio(cont, archive);
            if(contRelation.ContactCode__c != null)
            {
                sobjToUpdate.add(contRelation);
            }
            if(!sobjToUpdate.isEmpty())
            {
                HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
            }
        }
        catch(Exception e){
            HDT_SRV_LogService log = new HDT_SRV_LogService('HDT_BPCA_CREATE');
            log.insertSingleLog('BpCaRequest', 'makeRequest', 'N/A', 'N/A', e.getMessage() + '. At line: ' + e.getLineNumber(), acc.Id, System.now(), system.now());
        }
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
                acc.CustomerCode__c = res.data.codiceBP;
                update acc;
            }
            /* Commentato in quanto errata gestione della registrazione dell'amministratore */
            /*else if(('Grandi Condomini'.equalsIgnoreCase(acc.Category__c) || 'Piccoli Condomini'.equalsIgnoreCase(acc.Category__c))&& ('BP non rilevato'.equalsIgnoreCase(res.data.commenti))) {
                // amministratore di condominio viene identificato  dalla category 
                req = callAmCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert amministratore
               // System.debug('resCreate AMM : ' + resCreate);
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.CustomerCode__c = resCreate.data.codiceBP; 
                    update acc;
                } // TODO gestire l'errore 
            }*/
            /**@frpanico 17/01/2022
             * Commentata parte di codice della creazione Account
             * L'account viene creato in un secondo momento
             * Per gestire correttamente nuova e vecchia marcatura.
             */
/*             else if ( 'BP non rilevato'.equalsIgnoreCase(res.data.commenti)){
                req=callBpCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert
              //  System.debug('resCreate BP : ' + resCreate);
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.CustomerCode__c = resCreate.data.codiceBP; 
                    update acc;
                } // TODO gestire l'errore 
            } */
        } // TODO else per la gestione dell'errore
        //return acc;
    }
    public static Account analizeMassiveResponse(HDT_WS_RichCreBpCaResponse res,account acc,Contact cont ){
        HDT_WS_RicCreBpCaRequest   req;
        HDT_WS_RichCreBpCaResponse resCreate;
        if ('success'.equalsIgnoreCase(res.status)) {
            if (!'Errore'.equalsIgnoreCase(res.data.tipoAttivita)) {
                acc.CustomerCode__c = res.data.codiceBP;
               // update acc;
            }
            // else if('Grandi Condomini'.equalsIgnoreCase(acc.Category__c) || 'Piccoli Condomini'.equalsIgnoreCase(acc.Category__c)) {
            //     // amministratore di condominio viene identificato  dalla category 
            //     req = callAmCaCreate(acc,cont);
            //     resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert amministratore
            //     if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
            //         acc.CustomerCode__c = resCreate.data.codiceBP; 
            //      //   update acc;
            //     } // TODO gestire l'errore 
            // }
            // else {
            //     req=callBpCaCreate(acc,cont);
            //     resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert
            //     if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
            //         acc.CustomerCode__c = resCreate.data.codiceBP; 
            //        // update acc;
            //     } // TODO gestire l'errore 
            // }
        } // TODO else per la gestione dell'errore
        return acc;
    }
    public static String getStateIso(String state){
        String varIso='';
        Map<String, String> mapIso = new Map<String, String>{'EMIRATI ARABI UNITI'=>'AE','ANTIGUA/BARBUDA'=>'AG','ANGUILLA'=>'AI','ALBANIA'=>'AL','ARMENIA'=>'AM','ANTILLE OLANDESI'=>'AN','ANGOLA'=>'AO','ARGENTINA'=>'AR','SAMOA (USA)'=>'AS','AUSTRIA'=>'AT','AUSTRALIA'=>'AU','ARUBA'=>'AW','AZERBAIGIAN'=>'AZ','BOSNIA-ERZEGOVINA'=>'BA','BARBADOS'=>'BB','BANGLADESH'=>'BD','BELGIO'=>'BE',
        'BURKINA FASO'=>'BF','BULGARIA'=>'BG','BAHREIN'=>'BH','BURUNDI'=>'BI','BENIN'=>'BJ','BERMUDE'=>'BM','BRUNEI'=>'BN','BOLIVIA'=>'BO','BRASILE'=>'BR','BAHAMA'=>'BS','BHUTAN'=>'BT','BOTSWANA'=>'BW','BIELORUSSIA'=>'BY','BELIZE'=>'BZ','CANADA'=>'CA','ISOLE COCOS'=>'CC','REP. DEMOCRATICA CO'=>'CD','CENTRAFRICA'=>'CF','REPUBBLICA DEL CONG'=>'CG','SVIZZERA'=>'CH','COSTA D\'AVORIO'=>'CI','ARCIPELAGO DI COOK'=>'CK','CILE'=>'CL','CAMERUN'=>'CM','CINA'=>'CN','COLOMBIA'=>'CO','COSTA RICA'=>'CR','CUBA'=>'CU',
        'CIPRO'=>'CV','ISOLE CHRISTMAS'=>'CX','CIPRO'=>'CY','REPUBBLICA CECA'=>'CZ','GERMANIA'=>'DE','GIBUTI'=>'DJ','DANIMARCA'=>'DK','DOMINICA'=>'DM','REPUBBLICA DOMINICA'=>'DO','ALGERIA'=>'DZ','ECUADOR'=>'EC','ESTONIA'=>'EE','EGITTO'=>'EG','ERITREA'=>'ER','SPAGNA'=>'ES','ETIOPIA'=>'ET','FINLANDIA'=>'FI','ISOLE FIGI'=>'FJ','ISOLE FALKLAND'=>'FK','ISOLE FAEROER'=>'FO','FRANCIA'=>'FR','GABON'=>'GA','GRAN BRETAGNA'=>'GB','GRENADA'=>'GD','GEORGIA'=>'GE','GUIANA FRANCESE'=>'GF','GHANA'=>'GH',
        'GIBILTERRA'=>'GI','GROENLANDIA'=>'GL','GAMBIA'=>'GM','REPUBBLICA DI GUINE'=>'GN','GUADALUPA'=>'GP','GUINEA EQUATORIALE'=>'GQ','GRECIA'=>'GR','GEORGIA DEL SUD E S'=>'GS','GUATEMALA'=>'GT','GUAM'=>'GU','GUINEA-BISSAU'=>'GW','GUIANA'=>'GY','HONG KONG'=>'HK','HONDURAS'=>'HN','CROAZIA'=>'HR','HAITI'=>'HT','UNGHERIA'=>'HU','INDONESIA'=>'ID','IRLANDA'=>'IE','ISRAELE'=>'IL','INDIA'=>'IN','IRAQ'=>'IQ','IRAN'=>'IR','ISLANDA'=>'IS','ITALIA'=>'IT','GIAMAICA'=>'JM','GIORDANIA'=>'JO','GIAPPONE'=>'JP','KENYA'=>'KE','KIRGHIZISTAN'=>'KG','CAMBOGIA'=>'KH',
        'KIRIBATI'=>'KI','COMORE'=>'KM','SAN CRISTOFORO E NE'=>'KN','COREA DEL NORD'=>'KP','COREA DEL SUD'=>'KR','KUWAIT'=>'KW','CAYMAN'=>'KY','KAZAKISTAN'=>'KZ','LAOS'=>'LA','LIBANO'=>'LB','SANTA LUCIA'=>'LC','LIECHTENSTEIN'=>'LI','SRI LANKA'=>'LK','LIBERIA'=>'LR','LESOTHO'=>'LS','LITUANIA'=>'LT','LUSSEMBURGO'=>'LU','LETTONIA'=>'LV','LIBIA'=>'LY','MAROCCO'=>'MA','MONTECARLO'=>'MC','MOLDAVIA'=>'MD','MADAGASCAR'=>'MG','ISOLE MARSHALL'=>'MH','MACEDONIA'=>'MK','MALI'=>'ML','MYANMAR (UNIONE)'=>'MM',
        'MONGOLIA'=>'MN','MACAO'=>'MO','ISOLE MARIANNE'=>'MP','MARTINICA'=>'MQ','MAURITANIA'=>'MR','MONTSERRAT'=>'MS','MALTA'=>'MT','MAURIZIO'=>'MU','MALDIVE'=>'MV','MALAWI'=>'MW','MESSICO'=>'MX','MALAISIA'=>'MY','MOZAMBICO'=>'MZ','NAMIBIA'=>'NA','NUOVA CALEDONIA'=>'NC','NIGER'=>'NE',
        'ISOLA DI NORFOLK'=>'NF','NIGERIA'=>'NG','NICARAGUA'=>'NI','OLANDA'=>'NL','NORVEGIA'=>'NO','NEPAL'=>'NP','NAURU'=>'NR','NUOVA ZELANDA'=>'NZ','OMAN'=>'OM','PANAMA'=>'PA','PERU\''=>'	PE','POLINESIA FRANCESE'=>'PF','PAPUA-NUOVA GUINEA'=>'PG','FILIPPINE'=>'PH','PAKISTAN'=>'PK','POLONIA'=>'PL','SAINT-PIERRE ET MIQ'=>'PM',
        'PITCAIRN'=>'PN','PORTORICO'=>'PR','PORTOGALLO'=>'PT','ISOLE PALAU'=>'PW','PARAGUAY'=>'PY','QATAR'=>'QA','REUNION'=>'RE','ROMANIA'=>'RO','RUSSIA'=>'RU','RUANDA'=>'RW','ARABIA SAUDITA'=>'SA','ISOLE SALOMONE'=>'SB','SEYCHELLES'=>'SC','SUDAN'=>'SD','SVEZIA'=>'SE','SINGAPORE'=>'SG',
        'ASCENSION'=>'SH','SLOVENIA'=>'SI','REPUBBLICA SLOVACCA'=>'SK','SIERRA LEONE'=>'SL','SAN MARINO'=>'SM','SENEGAL'=>'SN','SOMALIA'=>'SO','SURINAME'=>'SR','SAO TOME\' E PRINCIP'=>'ST','UNIONE SOVIETICA'=>'SU','SALVADOR'=>'SV','SIRIA'=>'SY','SWAZILAND'=>'SZ','TURKS E CAICOS'=>'TC',
        'CIAD'=>'TD','ANTARTIDE FRANCESE'=>'TF','TOGO'=>'TG','TAILANDIA'=>'TH','TAGISKISTAN'=>'TJ','ISOLE TOKELAU'=>'TK','TURKMENISTAN'=>'TM','TUNISIA'=>'TN','TONGA'=>'TO','TIMOR ORIENTALE'=>'TP','TURCHIA'=>'TR','TRINIDAD E TOBAGO'=>'TT','TUVALU'=>'TV','TAIWAN'=>'TW','TANZANIA'=>'TZ','UCRAINA'=>'UA','UGANDA'=>'UG','ISOLE MINORI (USA)'=>'UM','STATI UNITI D\'AMERI'=>'US','URUGUAY'=>'UY','UZBEKISTAN'=>'UZ','CITTA\' DEL VATICANO'=>'VA','SAINT VINCENT E GRE'=>'VC','VENEZUELA'=>'VE','ISOLE VERGINI (BRIT'=>'VG','ISOLE VERGINI (USA)'=>'VI',
        'VIETNAM'=>'VN','VANUATU'=>'VU','WALLIS E FUTUNA'=>'WF','SAMOA OCCIDENTALI'=>'WS','KOSOVO'=>'XZ','YEMEN'=>'YE','MAYOTTE'=>'YT','SERBIA E MONTENEGRO'=>'YU','SUD AFRICA'=>'ZA','ZAMBIA'=>'ZM','ZAIRE'=>'ZR','ZIMBABWE'=>'ZW'};
        if (String.isNotBlank (state)) {
            varIso=mapIso.get(state.toUpperCase())!=null ?mapIso.get(state.toUpperCase()):'';
        }
        return varIso;
        
    }

    public static String transcodeCustomerCategory(String category){
        String categoryCode = '';

        switch on category {
            when 'Famiglie' {
                categoryCode = 'Z001';
            }
            when 'Aziende Soho' {
                categoryCode = 'Z002';
            }
            when 'Aziende SME' {
                categoryCode = 'Z003';
            }
            when 'Enti' {
                categoryCode = 'Z004';
            }
            when 'Grandi Condomini' {
                categoryCode = 'Z005';
            }
            when 'Intercompany' {
                categoryCode = 'Z006';
            }
            when 'Salvaguardia Aziende' {
                categoryCode = 'Z007';
            }
            when 'Salvaguardia Enti' {
                categoryCode = 'Z009';
            }
            when 'Aziende TOP' {
                categoryCode = 'Z010';
            }
            when 'Piccoli Condomini' {
                categoryCode = 'Z011';
            }
            when 'Societa Vendita Terze' {
                categoryCode = 'Z012';
            }
            when 'Default gas' {
                categoryCode = 'Z013';
            }
            when 'Comuni Territorio' {
                categoryCode = 'Z016';
            }
            when 'FUI domestico' {
                categoryCode = 'Z019';
            }
            when 'FUI non domestico' {
                categoryCode = 'Z020';
            }
            when 'Reseller - Gruppo' {
                categoryCode = 'Z030';
            }
            when 'Reseller - Extra Gruppo' {
                categoryCode = 'Z031';
            }
        }

        return categoryCode;
    }

    /**@frpanico 17/01/2022
     * Creato metodo per la creazione del BP/CA
     */
    
    public static void createBpCa(List<AccountContactRelation> accountContactRelList, string saleId, Boolean searchToUse)
    {
        /**@frpanico 17/01/2022
         * Se presente accountContactRel Amm. Condominio/Legale Rappresentante
         * Viene utilizzato l'accountContactRel dell'Amministratore di Condominio/Legale Rappresentante
         * Altrimenti viene utilizzato quello titolare
         */

        Map<String, SObject> accountContactMap = new Map<String, SObject>();
        Boolean isAmministratore = false;
        try{
            for(AccountContactRelation accountContactRel : accountContactRelList){
                //AccountContactRelation del Amm. o del Legale se presenti
                if( accountContactRel.Roles.equalsIgnoreCase('Amministratore condominio') || accountContactRel.Roles.equalsIgnoreCase('Legale rappresentante')){
                    accountContactMap = generateAccountContact(accountContactRel);
                    if( accountContactRel.Roles.equalsIgnoreCase('Amministratore condominio')){
                        isAmministratore = true;
                    }
                    break;
                }else if( accountContactRel.Roles == 'Titolare' || accountContactRel.Roles == 'Familiare'){
                    //if AccountId not in the list yet, insert
                    if( !accountContactMap.containsKey('Account')){
                        accountContactMap = generateAccountContact(accountContactRel);
                    }
                }
            }
            /**@frpanico 09/02/2022
             * Se presente il customer code
             * Non viene registrato su sap l'account
             */
            if(String.isBlank(((String)((Account)accountContactMap.get('Account')).get('CustomerCode__c'))))
            {
                //CustomerMarking D* and update
                Account acc = checkCustomerMarking( (Account)accountContactMap.get('Account') , saleId );
                Contact cont = (Contact)accountContactMap.get('Contact');
            
                //HRADTR_GV Modifiche 03/02/2022 - Inizio
                List<SObject> listToUpdate = new List<SObject>();
                HDT_WS_RicCreBpCaRequest   req;
                HDT_WS_RichCreBpCaResponse resCreate;
                //HRADTR_GV Modifiche 31/03/2022 - Inizio
                if(searchToUse){
                    req = callBpCaSearch(acc,cont);
                    acc.Description = System.now() + ' : Account ricercato su SAP';
                }
                else{
                    req = callBpCaCreate(acc,cont);
                    acc.Description = System.now() + ' : Account creato';
                }
                //HRADTR_GV Modifiche 31/03/2022 - Fine
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.CustomerCode__c = resCreate.data.codiceBP;
                } // TODO gestire l'errore 

                if((acc.Category__c.equalsIgnoreCase('Grandi Condomini') || acc.Category__c.equalsIgnoreCase('Piccoli Condomini')) && isAmministratore ){
                    req = callAmCaCreate(acc,cont);
                    resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert
                    if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                        cont.ContactCode__c = resCreate.data.codiceBP;
                    } // TODO gestire l'errore 
                }
                listToUpdate.add(acc);
                listToUpdate.add(cont); 
                HDT_UTL_DatabaseService.updateSObject( listToUpdate ); 
            }
            else
            {
                return;    
            }
            //HRADTR_GV Modifiche 03/02/2022 - Fine
        }
        catch(Exception e)
        {  
            HDT_SRV_LogService log = new HDT_SRV_LogService('HDT_BPCA_SALE');
            log.insertSingleLog('BpCaRequest', 'createBpCa', 'N/A', 'N/A', e.getMessage() + '. At line: ' + e.getLineNumber(), saleId, System.now(), system.now());
        }
    }
    @TestVisible
    private static Account checkCustomerMarking( Account acc , string saleId)
    {
        //Modifiche HRADTR_GV 03/02/2022 - Inizio
        Boolean checkSaleId = false;
        Set<String> stabbedData = new Set<String>{'AQ', 'CH', 'PE', 'TE', 'AN', 'AP', 'FM', 'MC', 'PU'};//province abbruzzo e marche
        
        if(saleId instanceof Id){
            List<Sale__c> isAccountInTransition = [ SELECT Id, Account__c, isTransition__c FROM Sale__c WHERE Sale__c.Id=:saleId WITH SECURITY_ENFORCED ]; 
            checkSaleId = isAccountInTransition[0].IsTransition__c;
        }
        else{
            checkSaleId = (!stabbedData.contains(saleId));
        }
        //Modifiche HRADTR_GV 03/02/2022 - FIne
        //IsTransition__c = false && CustomerMarking !LIKE «D*» (es. Persona Fisica)
        if(!checkSaleId){ //Modifiche HRADTR_GV 03/02/2022 
            switch on acc.CustomerMarking__c {
                when 'Persona fisica' {
                    acc.CustomerMarking__c = 'D1 - Persona fisica';
                }    
                when 'Ditta individuale' {
                    acc.CustomerMarking__c = 'D2 - Ditta individuale';
                }
                when 'Azienda' {
                    acc.CustomerMarking__c = 'D3 - Azienda';
                }
                when 'Parti comuni' {
                    acc.CustomerMarking__c = 'D4 - Parti comuni';
                }
                when 'Condominio' {
                    acc.CustomerMarking__c = 'D5 - Condominio';
                }
                when 'Associazione' {
                    acc.CustomerMarking__c = 'D6 - Associazione';
                }
                when 'BP Doppio' {
                    acc.CustomerMarking__c = 'D7 - BP Doppio';
                }
                when 'Marcatura nulla' {
                    acc.CustomerMarking__c = 'D8 - Marcatura nulla';
                }
            }
        }
        return acc;
    }
    

    private static Map<String, SObject> generateAccountContact(AccountContactRelation accountContactRel)
    {
        accountContactRel = HDT_QR_AccountContactRelation.getAccountContactData(accountContactRel.Id)[0];

        Map<String, SObject> accountContactMap = new Map<String, SObject>();
        Account newAccount = new Account();
        Contact newContact = new Contact();
        Map<String, HDT_CreateBpCa__mdt> newBpCaMap = HDT_CreateBpCa__mdt.getAll(); 

        for( String strKey: newBpCaMap.keySet() ){ // strKey:FiscalCode__c, Id, ...
            if( newBpCaMap.get(strKey).Object__c == 'Account' ){
                if( !newBpCaMap.get(strKey).NotBlankable__c ){
                    if( newBpCaMap.get(strKey).Field__c == 'Id' ){
                        newAccount.put( newBpCaMap.get(strKey).Field__c, accountContactRel.AccountId );
                    }else if( accountContactRel.Account.get(newBpCaMap.get(strKey).Field__c) != null ){
                        newAccount.put( newBpCaMap.get(strKey).Field__c, accountContactRel.Account.get(newBpCaMap.get(strKey).Field__c) );
                    }else{
                        newAccount.put(newBpCaMap.get(strKey).Field__c,null); 
                    }
                }
            }else if( newBpCaMap.get(strKey).Object__c == 'Contact' ){
                if( !newBpCaMap.get(strKey).NotBlankable__c ){
                    if( newBpCaMap.get(strKey).Field__c == 'Id' ){
                        newContact.put( newBpCaMap.get(strKey).Field__c, accountContactRel.ContactId );
                    }else if( accountContactRel.Contact.get(newBpCaMap.get(strKey).Field__c)!=null ){     
                        newContact.put( newBpCaMap.get(strKey).Field__c, accountContactRel.Contact.get(newBpCaMap.get(strKey).Field__c));
                    }else{  
                        newContact.put(newBpCaMap.get(strKey).Field__c,null);  
                    }
                }
            }
        }

        accountContactMap.put('Account',newAccount);
        accountContactMap.put('Contact',newContact);
        return accountContactMap;
    }
    @TestVisible
    private static Contact registerAmmCondominio(Contact cont, Boolean archive)
    {
        Contact contactReturn = new Contact();
        Account administratorAccount = new Account();
        Boolean isAmministratoreCondominio = false;

        contactReturn.Id = cont.Id;

        List<AccountContactRelation> acrList = [SELECT Id,
        Roles,
        AccountId,
        Account.RecordTypeId,
        Account.Category__c,
        Account.CustomerMarking__c,
        Account.FiscalCode__c,
        Account.VatNumber__c,
        Account.FirstName__c,
        Account.BillingStreetNumber__c,
        Account.BillingStreetName__c,
        Account.BillingCountry,
        Account.BillingState,
        Account.BillingCity,
        Account.BillingPostalCode,
        Account.LastName__c,
        Account.CustomerCode__c,
        Account.MobilePhone__c,
        Account.Fax,
        Account.BuildingFloor__c,
        Account.PrimaryEmail__c,
        Account.VATGroup__c,
        Account.VATGroupStartDate__c,
        Account.VATGroupEndDate__c
        FROM AccountContactRelation
        WHERE ContactId = :cont.Id
        WITH SECURITY_ENFORCED];

        for(AccountContactRelation acr : acrList){
            if(acr.Roles!= null && acr.Roles.equalsIgnoreCase('Amministratore condominio')){
                isAmministratoreCondominio = true;
                /* Feed Account */
                administratorAccount.Id = acr.AccountId;
                administratorAccount.RecordTypeId = acr.Account?.RecordTypeId;
                administratorAccount.Category__c = acr.Account?.Category__c;
                administratorAccount.CustomerMarking__c = acr.Account?.CustomerMarking__c;
                administratorAccount.FiscalCode__c = acr.Account?.FiscalCode__c;
                administratorAccount.VatNumber__c = acr.Account?.VatNumber__c;
                administratorAccount.BillingStreetNumber__c = acr.Account?.BillingStreetNumber__c;
                administratorAccount.BillingStreetName__c = acr.Account?.BillingStreetName__c;
                administratorAccount.BillingCountry = acr.Account?.BillingCountry;
                administratorAccount.BillingState = acr.Account?.BillingState;
                administratorAccount.BillingCity = acr.Account?.BillingCity;
                administratorAccount.BillingPostalCode = acr.Account?.BillingPostalCode;
                administratorAccount.LastName__c = acr.Account?.LastName__c;
                administratorAccount.CustomerCode__c = acr.Account?.CustomerCode__c;
                administratorAccount.MobilePhone__c = acr.Account?.MobilePhone__c;
                administratorAccount.Fax = acr.Account?.Fax;
                administratorAccount.BuildingFloor__c = acr.Account?.BuildingFloor__c;
                administratorAccount.PrimaryEmail__c = acr.Account?.PrimaryEmail__c;
                administratorAccount.VATGroup__c = acr.Account?.VATGroup__c;
                administratorAccount.VATGroupStartDate__c = acr.Account?.VATGroupStartDate__c;
                administratorAccount.VATGroupEndDate__c = acr.Account?.VATGroupEndDate__c;
                break;
            }
        }
        /* Check if Roles Amministratore condominio and account category is either Grandi Codnomini or Piccoli Condomini */
        if(isAmministratoreCondominio && administratorAccount.Category__c != null && (administratorAccount.Category__c.equalsIgnoreCase('Grandi Condomini') || administratorAccount.Category__c.equalsIgnoreCase('Piccoli Condomini'))){
            /* Create Request */
            HDT_WS_RicCreBpCaRequest   req;
            HDT_WS_RichCreBpCaResponse resCreate;
            req = callAmCaCreate(administratorAccount,contactReturn);
            /* If its archive search on contact archive */
            if(archive)
            {
                List<SiebelContact__x> siebelContact = new List<SiebelContact__x>();
                siebelContact = [SELECT Id, INTEGRATION_ID__c 
                                    FROM SiebelContact__x 
                                    WHERE REFERENCE_TYPE_CD__c = 'Amministr. di condominio' 
                                    AND SOC_SECURITY_NUM__c = :contactReturn.FiscalCode__c LIMIT 1];
                /* If no contact is returned make the Am request registering the Amministratore condominio */
                if(siebelContact.isEmpty()){
                    resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req);
                    if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP)) {
                        contactReturn.ContactCode__c = resCreate.data.codiceBP;
                    }
                }
                /* If a contact is returned the contact code is saved */
                else
                {
                    contactReturn.ContactCode__c = siebelContact[0].INTEGRATION_ID__c;
                }
            }
            /* If it is not archive register the Amministratore Condominio */
            else
            {
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req);
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP)) {
                    contactReturn.ContactCode__c = resCreate.data.codiceBP;
                }
            }
        }
        
        return contactReturn;

    }

}