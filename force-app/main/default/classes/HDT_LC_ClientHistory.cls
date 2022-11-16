/**
* @author alessandro.picchiri@eng.it
* @date 20/05/2021
* @description Apex controller that returns list of customer in archive and in sf
*/

public with sharing class HDT_LC_ClientHistory {

    private static  Map<String, List<String>> mappingRoleToMarcatura = new Map<String, List<String>>{
        'HDT_BackOffice' => new List<String>{},
        'HDT_FrontOffice_Reseller' => new List<String>{},
        'HDT_FrontOffice_AAAEBT' => new List<String>{'AAS Persona fisica','AAS Ditta individuale','AAS Azienda','AAS Parti comuni','AAS Condominio','AAS Associazione'},
        'HDT_FrontOffice_HERA_COMM' => new List<String>{'D1 - Persona fisica', 'D2 - Ditta individuale', 'D3 - Azienda', 'D4 - Parti comuni', 'D5 - Condominio', 'D6 - Associazione', 'D7 - BP Doppio'},
        'HDT_FrontOffice_MMS' => new List<String>{'MMS Persona fisica','MMS Ditta individuale','MMS Azienda','MMS Parti comuni','MMS Condominio','MMS Associazione'}
    };
    
    //>>>START 25/10/2022 costanzo.lomele@webresults.it Wave 2
    private static  Map<String, List<String>> mappingRoleToCompanyOwner = new Map<String, List<String>>{
        'HDT_BackOffice' => new List<String>{},
        'HDT_FrontOffice_AAAEBT' => new List<String>{'AAA-EBT'},
        'HDT_FrontOffice_HERA_COMM' => new List<String>{'HERA COMM'},
        'HDT_FrontOffice_MMS' => new List<String>{'MMS'},
        'HDT_FrontOffice_Reseller' => new List<String>{'Reseller'}
    };
    //>>>END 25/10/2022 costanzo.lomele@webresults.it Wave 2

    public class HDT_LC_Link{
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public HDT_LC_Link(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    // Start Refactoring post intervento Andrea
    public class HDT_LC_Customer {
     
        @AuraEnabled public String Nome {get;set;}
        @AuraEnabled public String CodiceFiscale {get;set;}
        @AuraEnabled public String IVA {get;set;}
        @AuraEnabled public String CodiceCliente {get;set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String isStoricizzato {get;set;}
        @AuraEnabled public String NomeProprio {get;set;}
        @AuraEnabled public String silos {get;set;}
 
        public HDT_LC_Customer(String Nome,
                        String CodiceFiscale,
                        String IVA,
                        String CodiceCliente,
                        String Id,
                        String isStoricizzato,
                        String NomeProprio,
                        String silos
                        ){
                        this.Nome	        = Nome;	
                        this.CodiceFiscale	= CodiceFiscale;	
                        this.IVA	        = IVA;
                        this.CodiceCliente	= CodiceCliente;
                        this.Id	            = Id;
                        this.isStoricizzato = isStoricizzato;
                        this.NomeProprio    = NomeProprio;
                        this.silos          = silos;
                }             
     }
     // End Refactoring post intervento Andrea

    /*  La funzione restituisce la lista di marcature consentite in base al role dell'account in uso attualmente
    *
    *   return:
    *   null -> il role non è presente nella mappa, nessu risultato consentito
    *   List<String> vuoto: l'utente non ha alcun filtro
    *   List<String> popolato: la query verrà filtrata per le marcature restituite
    */
    public static List<String> getMarkingsFromRole(){
        String uRoleId = UserInfo.getUserRoleId();
        if(uRoleId != null){
            if (!Schema.sObjectType.UserRole.fields.DeveloperName.isAccessible()){
                return null;
            }
    
            String roleDevName = [SELECT DeveloperName FROM UserRole  WHERE Id = :uRoleId LIMIT 1].DeveloperName;
            
            return mappingRoleToMarcatura.get(roleDevName);
        }
        else return null;
    }
    
    public static List<String> getSilosFromRole(){
        String uRoleId = UserInfo.getUserRoleId();
        if(uRoleId != null){
            if (!Schema.sObjectType.UserRole.fields.DeveloperName.isAccessible()){
                return null;
            }    
            String roleDevName = [SELECT DeveloperName FROM UserRole  WHERE Id = :uRoleId LIMIT 1].DeveloperName;            
            return mappingRoleToCompanyOwner.get(roleDevName);
        }
        else return null;
    }
    
    @AuraEnabled
    public static List<HDT_LC_Customer> getExternalCustomer( String searchKey, String sortBy, String sortDirection, String filterby, String silos) {
        
        List <HDT_LC_Customer> wrapperToreturn = new List <HDT_LC_Customer>();

        // se il ruolo non è presente nella mappa allora non ha alcun permesso di visualizzazione sugli account

        List<String> marcaturePermesse = getMarkingsFromRole();
        system.debug(marcaturePermesse);
        if(marcaturePermesse == null){
            return wrapperToreturn;
        }

        List<String> silosPermessi = getSilosFromRole();
        system.debug(silosPermessi);
        if(silosPermessi != null && !silosPermessi.contains(silos)){
            return null;
        }
 
        if ( searchKey != null && searchKey != '' && searchKey.length() > 5) {

            //>>> QUERY SU SIEBELCUSTOMER
            String queryStoricizzati = 'select Id, ALIAS_NAME__c, TAX_IDEN_NUM__c ,VAT_REGN_NUM__c,NAME_1__c , OU_NUM__c FROM SiebelCustomer__x ';   
            if(filterby=='Codice Fiscale'){
                queryStoricizzati +=' WHERE TAX_IDEN_NUM__c = :searchKey';
            }else if(filterby=='Partita Iva'){
                queryStoricizzati += ' WHERE VAT_REGN_NUM__c = :searchKey';
            }else if(filterby=='Codice Cliente'){
                queryStoricizzati += ' WHERE OU_NUM__c = :searchKey';
            }

            if (marcaturePermesse.size() > 0)
                queryStoricizzati += ' AND X_MARCATURA_CLIENTE__c = :marcaturePermesse ';

            if (sortBy != null && sortDirection != null ) {
                queryStoricizzati += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            }
            List<SiebelCustomer__x> listSiebelCustomer = HDT_UTL_ObjectManagerTst.records(Database.query( String.escapeSingleQuotes(queryStoricizzati) )); 

            for(SiebelCustomer__x SiebelCustomer:listSiebelCustomer){
                wrapperToreturn.add(
                    new HDT_LC_Customer(
                        SiebelCustomer.ALIAS_NAME__c,                       
                        SiebelCustomer.TAX_IDEN_NUM__c,
                        SiebelCustomer.VAT_REGN_NUM__c,
                        SiebelCustomer.OU_NUM__c,
                        SiebelCustomer.Id,
                        'SI',
                        SiebelCustomer.NAME_1__c,
                        null
                        )
                );
            }
            
            //>>> QUERY SU SALESFORCECUSTOMER
            String querySvecchiati = 'select Id, FiscalCodeC__c, VATNumberC__c, CustomerCodeC__c, FirstNameC__c, LastNameC__c, CompanyOwnerC__c FROM SalesforceCustomer__x ';
            if(filterby=='Codice Fiscale'){
                querySvecchiati +=' WHERE FiscalCodeC__c = :searchKey';
            }else if(filterby=='Partita Iva'){
                querySvecchiati += ' WHERE VATNumberC__c = :searchKey';
            }else if(filterby=='Codice Cliente'){
                querySvecchiati += ' WHERE CustomerCodeC__c = :searchKey';
            }

            if (marcaturePermesse.size() > 0)
                querySvecchiati += ' AND CompanyOwnerC__c IN :silosPermessi ';

            if (sortBy != null && sortDirection != null ) {
                querySvecchiati += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            }
            List<SalesforceCustomer__x> listSalesforceCustomer = HDT_UTL_ObjectManagerTst.records(Database.query( String.escapeSingleQuotes(querySvecchiati) )); 

            for(SalesforceCustomer__x salesforceCustomer : listSalesforceCustomer){
                wrapperToreturn.add(
                    new HDT_LC_Customer(
                        salesforceCustomer.LastNameC__c,                       
                        salesforceCustomer.FiscalCodeC__c,
                        salesforceCustomer.VATNumberC__c,
                        salesforceCustomer.CustomerCodeC__c,
                        salesforceCustomer.Id,
                        'NO',
                        salesforceCustomer.FirstNameC__c,
                        salesforceCustomer.CompanyOwnerC__c
                        )
                );
            }
        }
        return wrapperToreturn;
    }
}