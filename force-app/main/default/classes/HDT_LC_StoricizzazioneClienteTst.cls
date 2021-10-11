/**
 * Header of the class "HDT_LC_StoricizzazioneClienteTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class ""HDT_LC_StoricizzazioneCliente"
 * @history
 * @Created 17/09/2021
 * Modified By:
 **/

@isTest
public class HDT_LC_StoricizzazioneClienteTst {    
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    @TestSetup
    static void makedata(){
        
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
            for(Account a : accs){
                a.FiscalCode__c='testFC';
                a.VATNumber__c='testVN';
                a.CustomerCode__c='testCC';
            }
            
            update accs;
            
		}
    }
    
    @isTest
    static void test1(){
        
        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Hera System Integrator');
        Id UserRoleId = HDT_UTL_DataFactoryTst.getUserRoleId('HDT_FrontOffice_HERA_COMM');
        User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId,false);
        u.UserRoleId = UserRoleid;
        insert u;
        
        system.runAs(u){
            Test.startTest();        
            
            HDT_LC_StoricizzazioneCliente.HDT_LC_Link link = new HDT_LC_StoricizzazioneCliente.HDT_LC_Link('testname','testvalue');
            
            List<HDT_LC_StoricizzazioneCliente.HDT_LC_Customer> listaCustomer1 = HDT_LC_StoricizzazioneCliente.getExternalCustomer('testFC', 'id', 'ASC', 'Codice Fiscale');
            List<HDT_LC_StoricizzazioneCliente.HDT_LC_Customer> listaCustomer2 = HDT_LC_StoricizzazioneCliente.getExternalCustomer('testVN', 'id', 'ASC', 'Partita Iva');
            List<HDT_LC_StoricizzazioneCliente.HDT_LC_Customer> listaCustomer3 = HDT_LC_StoricizzazioneCliente.getExternalCustomer('testCC', 'id', 'DESC', 'Codice Cliente');
            
            System.assertNotEquals(null, listaCustomer1, 'A list of account is not returned');
            
            List <Account> accounts = [select id from Account where CustomerMarking__c = 'Azienda'];
            List <Id> accountsId = new List<Id>();
            for (Account a : accounts){
                accountsId.add(a.id);
            }
            
            List<Id> customerId = new List<Id>();
            for(HDT_LC_StoricizzazioneCliente.HDT_LC_Customer a : listaCustomer1){
                customerId.add(a.id);
            }
            
            System.assertEquals(accountsId, customerId, 'The account with CustomerMarking__c = Azienda is not returned');

            Test.stopTest();
        }        
    }
}