/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 28/07/2021
 * @description HDT_SRV_CampaignMemberStatus Test Class
 * @history Lucas da Silva Fernandes – 28/07/2021 – Created Class
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@isTest
public with sharing class HDT_SRV_CampaignMemberStatusTst {

    @TestSetup
    static void setup(){

        List<Campaign> cp = HDT_UTL_DataFactoryTst.createCampaign(1, true);

        HDT_UTL_DataFactoryTst.createCampaignMemberStatus(1, true, cp[0].Id);

    }

    @isTest
    public static void testCheckCreateAccess() {
        
        Exception ex;
        String message;

        Test.startTest();

        User tUser=[SELECT Id, FirstName
                    FROM USER
                    WHERE UserPermissionsMarketingUser=true AND IsActive=true
                    LIMIT 1];

        System.runAs(tUser){
            
            try{

            HDT_SRV_CampaignMemberStatus.checkCreateAccess('Label');
                
            }catch(Exception e){
                ex = e;
                message = e.getMessage();
            }
            
        }

        Test.stopTest();
        
        System.assertEquals(null, ex, 'CheckCreateAccess did not work correctly');
        System.assertNotEquals('Non hai permessi per accedere ai campi ', message, 'CheckCreateAccess did not work correctly');

    }

    @isTest
    public static void testCheckAccessInit() {
        
        Exception ex;
        String message;

        Test.startTest();

        User tUser=[SELECT Id, FirstName
                    FROM USER
                    WHERE UserPermissionsMarketingUser=true AND IsActive=true
                    LIMIT 1];

        System.runAs(tUser){
            
            try{

            HDT_SRV_CampaignMemberStatus.checkAccessInit('Label', 'create');
                
            }catch(Exception e){
                ex = e;
                message = e.getMessage();
            }
        }
        
        Test.stopTest();
        
        System.assertEquals(null, ex, 'CheckCreateAccess did not work correctly');
        System.assertNotEquals('Non hai permessi per accedere ai campi ', message, 'CheckCreateAccess did not work correctly');
    }

    @isTest
    public static void testCreateRecord() {

        Test.startTest();

        User tUser=[SELECT Id, FirstName
                    FROM USER
                    WHERE UserPermissionsMarketingUser=true AND IsActive=true
                    LIMIT 1];

        System.runAs(tUser){

            List<CampaignMemberStatus> listCms = HDT_SRV_CampaignMemberStatus.createRecord(
                new List<CampaignMemberStatus> {new CampaignMemberStatus(
                                                Label = 'Test Label List',
                                                CampaignId = [SELECT Id FROM Campaign Limit 1].Id
            )});

            System.assertEquals('Test Label List', listCms[0].Label, 'Value of parameter is matching');

            System.assertNotEquals(listCms.isEmpty(), true, 'Value of parameter is not matching');

        }

        Test.stopTest();
    }
}