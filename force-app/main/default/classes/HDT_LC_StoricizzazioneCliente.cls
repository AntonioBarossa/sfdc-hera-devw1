/**
* @author alessandro.picchiri@eng.it
* @date 20/05/2021
* @description Apex controller that returns list of customer in archive and in sf
*/

public with sharing class HDT_LC_StoricizzazioneCliente {
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
    
    @AuraEnabled
    public static List<HDT_LC_Customer> getExternalCustomer( String searchKey, String sortBy, String sortDirection, String filterby) {
       System.debug('getExternalCustomer');
        
        List <HDT_LC_Customer> wrapperToreturn = new List <HDT_LC_Customer>();
 
        if ( searchKey != null && searchKey != '' && searchKey.length() > 5) {
            
            String queryStoricizzati = 'select Id, ALIAS_NAME__c, TAX_IDEN_NUM__c ,VAT_REGN_NUM__c,NAME_1__c , OU_NUM__c FROM SiebelCustomer__x ';   
            if(filterby=='Codice Fiscale'){
                queryStoricizzati +=' WHERE TAX_IDEN_NUM__c = :searchKey';
            }else if(filterby=='Partita Iva'){
                queryStoricizzati += ' WHERE VAT_REGN_NUM__c = :searchKey';
            }else if(filterby=='Codice Cliente'){
                queryStoricizzati += ' WHERE OU_NUM__c = :searchKey';
            }     
            if (sortBy != null && sortDirection != null ) {
                queryStoricizzati += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            }
            List<SiebelCustomer__x> listSiebelCustomer = Database.query( String.escapeSingleQuotes(queryStoricizzati) ); 

            String queryNonStoricizzati = 'select Id, FirstName__c,LastName__c  , FiscalCode__c ,VATNumber__c, CustomerCode__c FROM Account ';   
            if(filterby=='Codice Fiscale'){
                queryNonStoricizzati +=' WHERE FiscalCode__c = :searchKey';
            }else if(filterby=='Partita Iva'){
                queryNonStoricizzati += ' WHERE VATNumber__c = :searchKey';
            }else if(filterby=='Codice Cliente'){
                queryNonStoricizzati += ' WHERE CustomerCode__c = :searchKey';
            }     
            if (sortBy != null && sortDirection != null ) {
                queryNonStoricizzati += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            } 
            List<Account> listAccount =  Database.query( String.escapeSingleQuotes(queryNonStoricizzati) );
          

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
}