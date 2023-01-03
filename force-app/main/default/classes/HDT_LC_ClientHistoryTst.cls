/**
 * Header of the class "HDT_LC_ClientHistoryTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class ""HDT_LC_ClientHistory"
 * @history
 * @Created 17/09/2021
 * Modified By:
 **/

@isTest
public class HDT_LC_ClientHistoryTst {
    
    @TestSetup
    static void setup(){
        
        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Hera System Integrator');
        Id userRoleId = HDT_UTL_DataFactoryTst.getUserRoleId('HDT_FrontOffice_HERA_COMM');
        User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId,false);
        u.UserRoleId = UserRoleid;
        insert u;

    }
    
    @isTest static void testNoCustomer(){

        User u = [SELECT Id FROM User WHERE Email = 'crmuser@test.com' LIMIT 1];
        
        system.runAs(u){
            
            new HDT_LC_ClientHistory.HDT_LC_Link('testname','testvalue');
            
            new HDT_LC_ClientHistory.HDT_LC_Customer('Nome','CodiceFiscale', 'IVA', 'CodiceCliente', 'Id', 'isStoricizzato', 'NomeProprio', 'HERA COMM');
            
        	Test.startTest();           
            
            List<HDT_LC_ClientHistory.HDT_LC_Customer> listaCustomer = HDT_LC_ClientHistory.getExternalCustomer('taxtax', 'id', 'ASC', 'Codice Fiscale', 'HERA COMM');

            Test.stopTest();
            
            System.assertNotEquals(null, listaCustomer, 'HDT_LC_ClientHistory did not work correctly'); 

        }
    }

    @IsTest
    static void testFull(){
        
        User u = [SELECT Id FROM User WHERE Email = 'crmuser@test.com' LIMIT 1];
    
        system.runAs(u){
            
            new HDT_LC_ClientHistory.HDT_LC_Link('testname','testvalue');
            
            new HDT_LC_ClientHistory.HDT_LC_Customer('Nome','CodiceFiscale', 'IVA', 'CodiceCliente', 'Id', 'isStoricizzato', 'NomeProprio', 'HERA COMM');
            
            List<SiebelCustomer__x> siebels = new List<SiebelCustomer__x>();
            SiebelCustomer__x siebel = new SiebelCustomer__x(TAX_IDEN_NUM__c = 'taxtax', VAT_REGN_NUM__c = 'vat', OU_NUM__c = 'ou', ALIAS_NAME__c = 'sib');
            siebels.add(siebel);

            List<SalesforceCustomer__x> salesforces = new List<SalesforceCustomer__x>();
            SalesforceCustomer__x salesforce = new SalesforceCustomer__x(LastNameC__c = 'lastName', FiscalCodeC__c = 'fiscalCode', 
                                                                    VATNumberC__c = 'vatNumber', CustomerCodeC__c = 'customerCode', 
                                                                    FirstNameC__c = 'firstName', CompanyOwnerC__c = 'companyOwner');
            salesforces.add(salesforce);
            
            Test.startTest();

            HDT_UTL_ObjectManagerTst.setMock(new HDT_UTL_MockInterfaceOverrideTst(siebels));
            List<HDT_LC_ClientHistory.HDT_LC_Customer> listaCustomer = HDT_LC_ClientHistory.getExternalCustomer('taxtax', 'id', 'ASC', 'Codice Fiscale', 'HERA COMM', 'SiebelCustomer__x');
            HDT_UTL_ObjectManagerTst.setMock(new HDT_UTL_MockInterfaceOverrideTst(salesforces));
            listaCustomer.addAll(HDT_LC_ClientHistory.getExternalCustomer('taxtax', 'id', 'ASC', 'Codice Fiscale', 'HERA COMM', 'SalesforceCustomer__x'));

            Test.stopTest();
            
            System.assertNotEquals(null, listaCustomer, 'HDT_LC_ClientHistory did not work correctly');            
            System.assertEquals(2, listaCustomer.size(), 'HDT_LC_ClientHistory did not work correctly');
            
        }
    }
}