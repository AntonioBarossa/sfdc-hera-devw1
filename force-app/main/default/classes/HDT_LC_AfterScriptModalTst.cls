/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 13/10/2021
* @description HDT_LC_AfterScriptModal for Test Classes
* @history Elfrida Kora – 13/10/2021 – Created class
*/


@IsTest
public class HDT_LC_AfterScriptModalTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    
    @TestSetup
    static void makeData(){
        
        User admin = HDT_UTL_DataFactoryTst.createInternalUser( HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME), false);
        admin.UserRoleId = HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_BACKOFFICE);

        insert admin;
        
        System.runAs(admin) {

            List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, true, accountList[0].Id);
            
            HDT_UTL_DataFactoryTst.createCommunityUser(contacts[0], HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_DOOR2DOOR_PARTNER_NAME), true);

        }
       
    }
    
    @IsTest
    static void testOne(){
        User user=[SELECT  id FROM User WHERE Alias = 'commuser'];

        System.runAs(user){
             
        Test.startTest();

            
        Map<String,Object> res = HDT_LC_AfterScriptModal.initPostSaleAction();        

        System.assertEquals(true, res.get('isCommunity'),'Should be true because user is community');
        System.assertNotEquals(null, res.get('isCommunity'),'An answer should be present');

        Test.stopTest();
        }
    }
    

}