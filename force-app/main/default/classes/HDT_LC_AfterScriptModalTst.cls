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
        
           
           
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Community%' LIMIT 1];
		User tUser=HDT_UTL_DataFactoryTst.createCommunityUser(new Contact(), p.Id, true);
        
       
    }
    
    @IsTest
    static void testOne(){
         User user=[SELECT  id FROM User WHERE Email = 'commuser@test.com'];
         System.runAs(user){
             
                    Test.startTest();

            
    Map<String,Object> res = HDT_LC_AfterScriptModal.initPostSaleAction();
                         Test.stopTest();

        System.assertEquals(1, res.size(),'returns 1 because  has 1 field different');
        System.assertNotEquals(null, res.get('isCommunity'),' return null because has more than one field different ');
        }
    }
    

}