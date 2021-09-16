/**
* @author alessandro.picchiri@eng.it
* @date 20/05/2021
* @description HDT_LC_StoricizzazioneCliente - Apex controller that returns list of customer in archive and in sf
*/

public with sharing class HDT_LC_StoricizzazioneCliente {
    private static  Map<String, List<String>> mappingRoleToMarcatura = new Map<String, List<String>>{
        'HDT_BackOffice' => new List<String>{},
        'HDT_FrontOffice_AAAEBT' => new List<String>{'AAS Persona fisica','AAS Ditta individuale','AAS Azienda','AAS Parti comuni','AAS Condominio','AAS Associazione'},
        'HDT_FrontOffice_HERA_COMM' => new List<String>{'Persona fisica','Ditta individuale','Azienda','Parti comuni','Condominio','Associazione'},
        'HDT_FrontOffice_MMS' => new List<String>{'MMS Persona fisica','MMS Ditta individuale','MMS Azienda','MMS Parti comuni','MMS Condominio','MMS Associazione'}
    };

    /**
     * @description HDT_LC_Link
     */
    public class HDT_LC_Link{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        /**
         * @description HDT_LC_Link
         * param label - String
         * param value - String
         */
        public HDT_LC_Link(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    // Start Refactoring post intervento Andrea

    /**
     * @description HDT_LC_Customer
     */
    public class HDT_LC_Customer {
        
        /**
         * @description name - String variable
         */
        @AuraEnabled public String nome {get;set;}

        /**
         * @description codiceFiscale - String variable
         */
        @AuraEnabled public String codiceFiscale {get;set;}

        /**
         * @description iVA - String variable
         */
        @AuraEnabled public String iVA {get;set;}

        /**
         * @description codiceCliente - String variable
         */
        @AuraEnabled public String codiceCliente {get;set;}

        /**
         * @description id - String variable
         */
        @AuraEnabled public String id {get;set;}

        /**
         * @description isStoricizzato - String variable
         */
        @AuraEnabled public String isStoricizzato {get;set;}

        /**
         * @description nomeProprio - String variable
         */
        @AuraEnabled public String nomeProprio {get;set;}
        
        /**
         * @description HDT_LC_Customer
         * param nome - String
         * param codiceFiscale - String
         * param iva - String
         * param codiceCliente - String
         * param id - String
         * param isStoricizzato - String
         * param nomeProprio - String
         */
        public HDT_LC_Customer(String nome,
                        String codiceFiscale,
                        String iva,
                        String codiceCliente,
                        String id,
                        String isStoricizzato,
                        String nomeProprio
                        ){
                        this.nome	        = nome;	
                        this.codiceFiscale	= codiceFiscale;	
                        this.iva	        = ova;
                        this.codiceCliente	= codiceCliente;
                        this.id	            = id;
                        this.isStoricizzato = isStoricizzato;
                        this.nomeProprio    = nomeProprio;
                }             
     }
     // End Refactoring post intervento Andrea

    /**
     * @description HDT_LC_StoricizzazioneCliente.getMarcatureFromRole - La funzione restituisce la lista 
     *                                                                   di marcature consentite in base al 
     *                                                                     role dell'account in uso attualmente
     * param1 searchKey - String
     * param2 sortBy - String
     * param3 sortDirection - String
     * param4 filterby - String
     * @return null -> il role non è presente nella mappa, nessu risultato consentito
     * @return List<String> vuoto: l'utente non ha alcun filtro
     * @return List<String> popolato: la query verrà filtrata per le marcature restituite
     */
    public static List<String> getMarcatureFromRole(){
        String uRoleId = UserInfo.getUserRoleId();

        if (!Schema.sObjectType.UserRole.fields.DeveloperName.isAccessible()){
            return null;
        }

        String roleDevName = [SELECT DeveloperName FROM UserRole  WHERE Id = :uRoleId LIMIT 1].DeveloperName;
        
        return mappingRoleToMarcatura.get(roleDevName);
    }
    
    /**
     * @description HDT_LC_StoricizzazioneCliente.getExternalCustomer
     * param1 searchKey - String
     * param2 sortBy - String
     * param3 sortDirection - String
     * param4 filterby - String
     * @return List<HDT_LC_Customer>
     */
    @AuraEnabled
    public static List<HDT_LC_Customer> getExternalCustomer( String searchKey, String sortBy, String sortDirection, String filterby) {
        System.debug('getExternalCustomer');
        //>>>START marco.arci@webresults.it Code Review
        Map<String,String> toQuery = new Map<String,String>();
        List <HDT_LC_Customer> wrapperToreturn = new List <HDT_LC_Customer>();
 
        if (!String.isBlank(searchKey) && searchKey.length() > 5) {

            List<String> marcaturePermesse = getMarcatureFromRole();
            // se il ruolo non è presente nella mappa allora non ha alcun permesso di visualizzazione sugli account
            if(marcaturePermesse == null){
                return wrapperToreturn;
            }
            toQuery = getExternalCustomerMapQuery(sortBy,sortDirection,filterby,marcaturePermesse);
            List<SiebelCustomer__x> listSiebelCustomer = Database.query( String.escapeSingleQuotes(toQuery.get('listSiebelCustomer')) ); 
            List<Account> listAccount =  Database.query( String.escapeSingleQuotes(toQuery.get('listAccount')) );
            //>>>END marco.arci@webresults.it Code Review

            for(SiebelCustomer__x siebelCustomer:listSiebelCustomer){
                wrapperToreturn.add(
                    new HDT_LC_Customer(
                        siebelCustomer.ALIAS_NAME__c,                       
                        siebelCustomer.TAX_IDEN_NUM__c,
                        siebelCustomer.VAT_REGN_NUM__c,
                        siebelCustomer.OU_NUM__c,
                        siebelCustomer.Id,
                        'SI',
                        siebelCustomer.NAME_1__c
                        )
                );
            }
 
            for(Account sfCustomer:listAccount){
                wrapperToreturn.add(
                    new HDT_LC_Customer(
                        sfCustomer.LastName__c,
                        sfCustomer.FiscalCode__c,
                        sfCustomer.VATNumber__c,
                        sfCustomer.CustomerCode__c,
                        sfCustomer.Id,
                        'NO',
                        sfCustomer.FirstName__c
                        )
                );
            }
        }
        System.debug('wrapperToreturn: '+wrapperToreturn);
        return wrapperToreturn;
    }

    //>>>START marco.arci@webresults.it Code Review
    /**
     * @author Marco Arci (marco.arci@webresults.it) Code Review
     * @description HDT_LC_StoricizzazioneCliente.getExternalCustomerMapQuery
     * param1 sortBy - String
     * param2 sortDirection - String
     * param3 filterby - String
     * param4 marcaturePermesse - List<String>
     * @return Map<string,string>
     */
    public static Map<string,string> getExternalCustomerMapQuery(String sortBy, String sortDirection, String filterby, List<String> marcaturePermesse) {
        Map<String,String> toQuery = new Map<String,String>();
        String queryStoricizzati = 'select Id, ALIAS_NAME__c, TAX_IDEN_NUM__c ,VAT_REGN_NUM__c,NAME_1__c , OU_NUM__c FROM SiebelCustomer__x ';   
        /*
        if(filterby=='Codice Fiscale'){
            queryStoricizzati +=' WHERE TAX_IDEN_NUM__c = :searchKey';
        }else if(filterby=='Partita Iva'){
            queryStoricizzati += ' WHERE VAT_REGN_NUM__c = :searchKey';
        }else if(filterby=='Codice Cliente'){
            queryStoricizzati += ' WHERE OU_NUM__c = :searchKey';
        }  
        */   
        queryStoricizzati += (filterby=='Codice Fiscale') ? ' WHERE TAX_IDEN_NUM__c = :searchKey' : (
                                (filterby=='Partita Iva') ? ' WHERE VAT_REGN_NUM__c = :searchKey' : (
                                (filterby=='Codice Cliente') ? ' WHERE OU_NUM__c = :searchKey' : ''));
        // filtro marcatura
        // queryStoricizzati += getQueryMarcaturaString(marcaturePermesse, 'SiebelCustomer__x');
        /*
        if (marcaturePermesse.size() > 0){
            queryStoricizzati += ' AND X_MARCATURA_CLIENTE__c = :marcaturePermesse ';
        }
        if (sortBy != null && sortDirection != null ) {
            queryStoricizzati += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        */
        queryStoricizzati += (marcaturePermesse.size() > 0) ? ' AND X_MARCATURA_CLIENTE__c = :marcaturePermesse ' : '' ;
        queryStoricizzati += (sortBy != null && sortDirection != null ) ? ' ORDER BY ' + sortBy + ' ' + sortDirection : '' ;

        toQuery.put('listSiebelCustomer',queryStoricizzati);


        String queryNonStoricizzati = 'select Id, FirstName__c,LastName__c  , FiscalCode__c ,VATNumber__c, CustomerCode__c FROM Account ';   
        /*
        if(filterby=='Codice Fiscale'){
            queryNonStoricizzati +=' WHERE FiscalCode__c = :searchKey';
        }else if(filterby=='Partita Iva'){
            queryNonStoricizzati += ' WHERE VATNumber__c = :searchKey';
        }else if(filterby=='Codice Cliente'){
            queryNonStoricizzati += ' WHERE CustomerCode__c = :searchKey';
        }     
        */
        queryNonStoricizzati += (filterby=='Codice Fiscale') ? ' WHERE FiscalCode__c = :searchKey' : (
                                (filterby=='Partita Iva') ? ' WHERE VATNumber__c = :searchKey' : (
                                (filterby=='Codice Cliente') ? ' WHERE CustomerCode__c = :searchKey' : ''));
        // filtro marcatura2
        /*
        if (marcaturePermesse.size() > 0){
            queryNonStoricizzati += ' AND CustomerMarking__c = :marcaturePermesse ';
        }
        if (sortBy != null && sortDirection != null ) {
            queryNonStoricizzati += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        } 
        */
        queryNonStoricizzati += (marcaturePermesse.size() > 0) ? ' AND CustomerMarking__c = :marcaturePermesse ' : '';
        queryNonStoricizzati += (sortBy != null && sortDirection != null ) ? ' ORDER BY ' + sortBy + ' ' + sortDirection : '';
        
        toQuery.put('listAccount',queryNonStoricizzati);
        return toQuery;
    }
    //>>>END marco.arci@webresults.it Code Review
}