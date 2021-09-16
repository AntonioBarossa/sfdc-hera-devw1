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

             System.assertEquals(True,myValue,'Value is ServiceUser');
             System.assertNotEquals(False,myValue,'Paolo is not the value that return'); 
         Test.stopTest();
                      

     }
     
      @isTest

     public static void testEvaluate1(){
          Test.startTest();
         HDT_UTL_ServiceCatalogProfileCriteria testMthod = new HDT_UTL_ServiceCatalogProfileCriteria();
         Map<String,String> argsMap = new Map<String,String>{'method' =>'CommunityUser'};
       boolean returnValue = testMthod.evaluate(argsMap);
         System.debug('returnValue' +returnValue);
          System.assertEquals(False,returnValue,'Claudia is not the value that return');
          System.assertNotEquals(True,returnValue,'Value is CommunityUser'); 
        Test.stopTest(); 
                  

     }

       
     
     

 }