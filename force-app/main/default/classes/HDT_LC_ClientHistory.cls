/**
* @author alessandro.picchiri@eng.it
* @date 20/05/2021
* @description Apex controller that returns list of customer in archive and in sf
*/

public with sharing class HDT_LC_ClientHistory {

    private static  Map<String, List<String>> mappingRoleToMarcatura = new Map<String, List<String>>{
        'HDT_BackOffice' => new List<String>{},
        'HDT_FrontOffice_AAAEBT' => new List<String>{'AAS Persona fisica','AAS Ditta individuale','AAS Azienda','AAS Parti comuni','AAS Condominio','AAS Associazione'},
        'HDT_FrontOffice_HERA_COMM' => new List<String>{'Persona fisica','Ditta individuale','Azienda','Parti comuni','Condominio','Associazione'},
        'HDT_FrontOffice_MMS' => new List<String>{'MMS Persona fisica','MMS Ditta individuale','MMS Azienda','MMS Parti comuni','MMS Condominio','MMS Associazione'}
    };

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
 
        public HDT_LC_Customer(String Nome,
                        String CodiceFiscale,
                        String IVA,
                        String CodiceCliente,
                        String Id,
                        String isStoricizzato,
                        String NomeProprio
                        ){
                        this.Nome	        = Nome;	
                        this.CodiceFiscale	= CodiceFiscale;	
                        this.IVA	        = IVA;
                        this.CodiceCliente	= CodiceCliente;
                        this.Id	            = Id;
                        this.isStoricizzato = isStoricizzato;
                        this.NomeProprio    = NomeProprio;
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

        if (!Schema.sObjectType.UserRole.fields.DeveloperName.isAccessible()){
            return null;
        }

        String roleDevName = [SELECT DeveloperName FROM UserRole  WHERE Id = :uRoleId LIMIT 1].DeveloperName;
        
        return mappingRoleToMarcatura.get(roleDevName);
    }
    
    @AuraEnabled
    public static List<HDT_LC_Customer> getExternalCustomer( String searchKey, String sortBy, String sortDirection, String filterby) {
        
        List <HDT_LC_Customer> wrapperToreturn = new List <HDT_LC_Customer>();
 
        if ( searchKey != null && searchKey != '' && searchKey.length() > 5) {

            List<String> marcaturePermesse = getMarkingsFromRole();
            
            system.debug(marcaturePermesse);
            // se il ruolo non è presente nella mappa allora non ha alcun permesso di visualizzazione sugli account
            if(marcaturePermesse == null){
                return wrapperToreturn;
            }
            
            String queryStoricizzati = 'select Id, ALIAS_NAME__c, TAX_IDEN_NUM__c ,VAT_REGN_NUM__c,NAME_1__c , OU_NUM__c FROM SiebelCustomer__x ';   
            if(filterby=='Codice Fiscale'){
                queryStoricizzati +=' WHERE TAX_IDEN_NUM__c = :searchKey';
            }else if(filterby=='Partita Iva'){
                queryStoricizzati += ' WHERE VAT_REGN_NUM__c = :searchKey';
            }else if(filterby=='Codice Cliente'){
                queryStoricizzati += ' WHERE OU_NUM__c = :searchKey';
            }     
            // filtro marcatura
            // queryStoricizzati += getQueryMarcaturaString(marcaturePermesse, 'SiebelCustomer__x');
            if (marcaturePermesse.size() > 0)
                queryStoricizzati += ' AND X_MARCATURA_CLIENTE__c = :marcaturePermesse ';

            if (sortBy != null && sortDirection != null ) {
                queryStoricizzati += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            }
            List<SiebelCustomer__x> listSiebelCustomer = HDT_UTL_ObjectManagerTst.records(Database.query( String.escapeSingleQuotes(queryStoricizzati) )); 
            
            //List<SiebelCustomer__x> listSiebelCustomer = Database.query( String.escapeSingleQuotes(queryStoricizzati) );
            
            //START>>> Modifica Task HRAWRM-691 marco.arci@webresults.it
            /*
            String queryNonStoricizzati = 'select Id, FirstName__c,LastName__c  , FiscalCode__c ,VATNumber__c, CustomerCode__c FROM Account ';   
            if(filterby=='Codice Fiscale'){
                queryNonStoricizzati +=' WHERE FiscalCode__c = :searchKey';
            }else if(filterby=='Partita Iva'){
                queryNonStoricizzati += ' WHERE VATNumber__c = :searchKey';
            }else if(filterby=='Codice Cliente'){
                queryNonStoricizzati += ' WHERE CustomerCode__c = :searchKey';
            }     
            // filtro marcatura
            if (marcaturePermesse.size() > 0)
                queryNonStoricizzati += ' AND CustomerMarking__c = :marcaturePermesse ';

            if (sortBy != null && sortDirection != null ) {
                queryNonStoricizzati += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            } 
            List<Account> listAccount =  Database.query( String.escapeSingleQuotes(queryNonStoricizzati) );
            */
            //END>>> Modifica Task HRAWRM-691 marco.arci@webresults.it

            for(SiebelCustomer__x SiebelCustomer:listSiebelCustomer){
                wrapperToreturn.add(
                    new HDT_LC_Customer(
                        SiebelCustomer.ALIAS_NAME__c,                       
                        SiebelCustomer.TAX_IDEN_NUM__c,
                        SiebelCustomer.VAT_REGN_NUM__c,
                        SiebelCustomer.OU_NUM__c,
                        SiebelCustomer.Id,
                        'SI',
                        SiebelCustomer.NAME_1__c
                        )
                );
            }
            //START>>> Modifica Task HRAWRM-691 marco.arci@webresults.it
            /*
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
            */
            //END>>> Modifica Task HRAWRM-691 marco.arci@webresults.it
        }
        return wrapperToreturn;
    }
}