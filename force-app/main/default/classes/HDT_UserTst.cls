/**
 * Header of the class "HDT_UserTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Trigger "HDT_User"
 * @history
 * @Created 22/09/2021
 * Modified By:
 **/

@isTest
public class HDT_UserTst {
    
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @isTest
    static void test1(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
                       
            Id profile = HDT_UTL_DataFactoryTst.getProfileId('Hera Standard User');           
            User u = HDT_UTL_DataFactoryTst.createInternalUser(profile,false);
            u.Alias = 'testef56';
            insert u;
            
            List<User> users = [Select id from User where Alias='testef56'];
            
            System.assertEquals(1, users.size(), 'User not inserted');
            
        }
     }
}