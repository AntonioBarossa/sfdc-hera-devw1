/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 13/09/2021
* @description HDT_UTL_ServiceCatalogProfileCriteria for Test Classes
* @history Elfrida Kora – 13/09/2021 – Created class
*/

 @IsTest
 public class HDT_UTL_ServiceCatalogProfileCriteriaTst {
 private static HDT_UTL_Constants constants = new HDT_UTL_Constants();    
    
     
     @TestSetup
     static void myData(){
         
          List<Individual> indList = HDT_UTL_DataFactoryTst.createIndividual(1,true);
          Id indId = indList[0].Id;
         HDT_UTL_DataFactoryTst.pClickInstance();
         HDT_UTL_DataFactoryTst.pClickOrderPhase();
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
    internalUser.UserPermissionsMarketingUser=true;
    internalUser.IsActive=true;
    insert internalUser;
         
        
     }
     
     
      @isTest
     public static void testEvaluate(){
         Test.startTest();
         HDT_UTL_ServiceCatalogProfileCriteria testMthod = new HDT_UTL_ServiceCatalogProfileCriteria();
         Map<String,String> argsMap = new Map<String,String>{'method' =>'ServiceUser'};
             boolean myValue = testMthod.evaluate(argsMap);
         System.debug('myValue++++++' +myValue);

             System.assertEquals(True,myValue,'HDT_UTL_ServiceCatalogProfileCriteria.evaluate user was not identified as ServiceUser');
             System.assertNotEquals(False,myValue,'HDT_UTL_ServiceCatalogProfileCriteria.evaluate user should have been indentified as ServiceUser');

         Test.stopTest();
                      

     }
     
      @isTest

     public static void testEvaluate1(){
          Test.startTest();
         HDT_UTL_ServiceCatalogProfileCriteria testMthod = new HDT_UTL_ServiceCatalogProfileCriteria();
         Map<String,String> argsMap = new Map<String,String>{'method' =>'CommunityUser'};
       boolean returnValue = testMthod.evaluate(argsMap);
         System.debug('returnValue' +returnValue);

          System.assertEquals(False,returnValue,'HDT_UTL_ServiceCatalogProfileCriteria.evaluate user was no identified as CommunityUser');
          System.assertNotEquals(True,returnValue,'HDT_UTL_ServiceCatalogProfileCriteria.evaluate user should have been indentified as CommunityUser'); 

        Test.stopTest(); 
                  

     }

       
     
     

 }