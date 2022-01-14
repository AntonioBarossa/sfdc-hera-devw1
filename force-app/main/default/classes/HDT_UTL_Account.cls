/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 16/07/2021
* @description HDT_UTL_Note
* @history Lorenzo – 16/07/2021 – created class
*/
public with sharing class HDT_UTL_Account {
    private static Id accRecordTypeIdResidenziale = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
    private static Id accRecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();

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
        req.codiceCausale            ='SRC';
        req.numeroSR                 = a.id;
        req.account.tipoAccount      = recordType;
        req.account.categoria        = a.category__c;
        req.account.telefono         = c.MobilePhone;
        req.account.emailCont        = c.email;
        req.account.marcaturaCliente = a.customerMarking__c;
        req.account.codiceFiscale    = recordType == 'Organizzazione' ? a.vatnumber__c : c.fiscalCode__c;
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
        req.account.indirizzo.toponimo	    = a.BillingStreetToponym__c;
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
       // System.debug('Response SRC : ' + res);
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
                acc.CustomerCode__c = res.data.codiceBP;
                update acc;
            }
          
            else if(('Grandi Condomini'.equalsIgnoreCase(acc.Category__c) || 'Piccoli Condomini'.equalsIgnoreCase(acc.Category__c))&& ('BP non rilevato'.equalsIgnoreCase(res.data.commenti))) {
                // amministratore di condominio viene identificato  dalla category 
                req = callAmCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert amministratore
               // System.debug('resCreate AMM : ' + resCreate);
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.CustomerCode__c = resCreate.data.codiceBP; 
                    update acc;
                } // TODO gestire l'errore 
            }
            else if ( 'BP non rilevato'.equalsIgnoreCase(res.data.commenti)){
                req=callBpCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert
              //  System.debug('resCreate BP : ' + resCreate);
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.CustomerCode__c = resCreate.data.codiceBP; 
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
                acc.CustomerCode__c = res.data.codiceBP;
               // update acc;
            }
            else if('Grandi Condomini'.equalsIgnoreCase(acc.Category__c) || 'Piccoli Condomini'.equalsIgnoreCase(acc.Category__c)) {
                // amministratore di condominio viene identificato  dalla category 
                req = callAmCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert amministratore
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.CustomerCode__c = resCreate.data.codiceBP; 
                 //   update acc;
                } // TODO gestire l'errore 
            }
            else {
                req=callBpCaCreate(acc,cont);
                resCreate = HDT_WS_RicCreBpCaInvoker.invokeCall(req); //  chiamata insert
                if ('success'.equalsIgnoreCase(resCreate.status) && String.isNotBlank(resCreate.data.codiceBP) ) {
                    acc.CustomerCode__c = resCreate.data.codiceBP; 
                   // update acc;
                } // TODO gestire l'errore 
            }
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

}