@isTest
public with sharing class HDT_UTL_LicenseAssignmentTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @isTest
    static void test1(){
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
                       
            Id profile = HDT_UTL_DataFactoryTst.getProfileId('HERA Standard User');           
            User u = HDT_UTL_DataFactoryTst.createInternalUser(profile,false);
            u.Alias = 'test1';
            insert u;
            
            Id profile2 = HDT_UTL_DataFactoryTst.getProfileId('Hera Standard User OneShot');           
            User u2 = HDT_UTL_DataFactoryTst.createInternalUser(profile2,false);
            u2.Alias = 'test2';
            insert u2;

            List<User> users = [Select id from User where Alias in ('test1','test2')];
            System.assertEquals(2, users.size(), 'User not inserted');
            
            PermissionSet psCpq=[select id from PermissionSet where LicenseId  in (select id from PermissionSetLicense where MasterLabel ='Salesforce CPQ License')  and name='HDT_SalesforceCPQLicense'];

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = psCpq.Id, AssigneeId = u.Id);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = psCpq.Id, AssigneeId = u2.Id);

            List<PermissionSetLicenseAssign> userLicenseAssignmentService=[select id,AssigneeId from PermissionSetLicenseAssign  where PermissionSetLicense.DeveloperName ='ServiceUserPsl' and Assignee.Profile.name in ('HERA Standard User','Hera Standard User OneShot') and Assignee.isActive=true];
            
            Integer sizeBefore=userLicenseAssignmentService.size();
            System.debug('check before:'+sizeBefore);
            
            HDT_UTL_LicenseAssignment.assignLicense();

            List<PermissionSetLicenseAssign> userLicenseAssignmentService2=[select id,AssigneeId from PermissionSetLicenseAssign  where PermissionSetLicense.DeveloperName ='ServiceUserPsl' and Assignee.Profile.name in ('HERA Standard User','Hera Standard User OneShot') and Assignee.isActive=true];

            Integer sizeAfter=userLicenseAssignmentService2.size();
            System.debug('check after:'+sizeAfter);

            System.assertEquals(2, (sizeAfter-sizeBefore), 'Perm not assigned');


            
            
            

        }
    }
    


}
