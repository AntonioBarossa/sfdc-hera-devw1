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
    
    @isTest static void test(){

        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Hera System Integrator');
        Id userRoleId = HDT_UTL_DataFactoryTst.getUserRoleId('HDT_FrontOffice_HERA_COMM');
        User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId,false);
        u.UserRoleId = UserRoleid;
        insert u;
        
        system.runAs(u){        
            
            new HDT_LC_StoricizzazioneCliente.HDT_LC_Link('testname','testvalue');
            
            new HDT_LC_StoricizzazioneCliente.HDT_LC_Customer('Nome','CodiceFiscale', 'IVA', 'CodiceCliente', 'Id', 'isStoricizzato', 'NomeProprio');
            
            List<SiebelCustomer__x> siebels = new List<SiebelCustomer__x>();
            SiebelCustomer__x siebel = new SiebelCustomer__x(TAX_IDEN_NUM__c = 'taxtax', VAT_REGN_NUM__c = 'vat', OU_NUM__c = 'ou', ALIAS_NAME__c = 'sib');
			siebels.add(siebel);

			HDT_UTL_ObjectManagerTst.setMock(new HDT_UTL_MockInterfaceOverrideTst(siebels));
        	Test.startTest();           
            
            List<HDT_LC_StoricizzazioneCliente.HDT_LC_Customer> listaCustomer = HDT_LC_StoricizzazioneCliente.getExternalCustomer('taxtax', 'id', 'ASC', 'Codice Fiscale');

            Test.stopTest();
            
            System.assertNotEquals(null, listaCustomer, 'HDT_LC_StoricizzazioneCliente did not work correctly');            
            System.assertEquals(1, listaCustomer.size(), 'HDT_LC_StoricizzazioneCliente did not work correctly');
        }
    }        
}