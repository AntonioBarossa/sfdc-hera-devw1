/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 10/08/2021
* @description Test Class for HDT_TRH_PushTracking
* @history Lucas da Silva Fernandes – 10/08/2021 – Created class
*/
@isTest
public with sharing class HDT_LC_GeolocationCommunityTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

        Id minimumAccessProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.MINIMUM_ACCESS_SALESFORCE);
        User minimumAccessUser=HDT_UTL_DataFactoryTst.createInternalUser(minimumAccessProfileId, false);
        minimumAccessUser.Email = 'sales@force.com';
        insert minimumAccessUser;

        System.runAs(internalUser) {
        
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            
            List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].Id);
            contactList[0].MailingLatitude = -34.397;
            contactList[0].MailingLongitude = 150.644;
            contactList[0].Phone = '0981516381';
            contactList[0].Email = 'test@salesforce.com';
            contactList[0].MailingCountry = 'Australia';
            insert contactList;

            List<Campaign> campaignList = HDT_UTL_DataFactoryTst.createCampaign(1, false);
            campaignList[0].Category__c = 'Campagna Outbound';
            //** [START MOD 2021-08-20] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Correct the wrong channel
            //campaignList[0].Channel__c = 'Door to Door';
            campaignList[0].Channel__c = 'Bolletta';
            //** [END MOD 2021-08-20] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Correct the wrong channel
            campaignList[0].IsActive = true;
            campaignList[0].StartDate = Date.today();
            campaignList[0].EndDate = Date.today()+15;
            insert campaignList;

            System.debug(campaignList[0].Id);
            

            List<CampaignMember> campaignMemberList = new List<CampaignMember>();

            List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, false);
            leadList[0].Phone = '055355788';
            leadList[0].Country = 'Australia';
            leadList[0].City = 'Sydney';
            leadList[0].Latitude = -34.397;
            leadList[0].Longitude = 150.644;
            insert leadList;

            CampaignMember cpm = new CampaignMember(
                CampaignId = campaignList[0].Id,
                ContactId = contactList[0].Id,
                LeadId = leadList[0].Id
            );

            campaignMemberList.add(cpm);

            insert campaignMemberList;
        }
    }

    @isTest
    public static void testGetContactsByOwnerId() {

        Test.startTest();

        Contact ctt = [SELECT Id, OwnerId, Name FROM Contact WHERE FirstName = 'test' LIMIT 1];

        List<Contact> cttList = HDT_LC_GeolocationCommunity.getContactsByOwnerId(ctt.OwnerId, ctt.Name);

        System.assertEquals(ctt.Id, cttList[0].Id, 'IDs match.');

        System.assertNotEquals(ctt.Id, '', 'IDs do not match.');

        //To reach exception
        User u=[SELECT Id FROM User WHERE Email='sales@force.com' LIMIT 1];

        System.runAs(u) {
            
            cttList = HDT_LC_GeolocationCommunity.getContactsByOwnerId(ctt.OwnerId, ctt.Name);
        }

        Test.stopTest();
    }

    @isTest
    public static void testGetContactCoordinates() {

        Test.startTest();

        Contact ctt = [SELECT Id, MailingLatitude, MailingLongitude FROM Contact WHERE FirstName = 'test' LIMIT 1];

        Contact cttTest = HDT_LC_GeolocationCommunity.getContactCoordinates(ctt.Id);

        System.assertEquals(ctt.MailingLatitude, cttTest.MailingLatitude, 'Latitude match');

        System.assertNotEquals(ctt.MailingLatitude, null, 'Latidude does not match');

        //To reach exception
        User u=[SELECT Id FROM User WHERE Email='sales@force.com' LIMIT 1];

        System.runAs(u) {
            
            cttTest = HDT_LC_GeolocationCommunity.getContactCoordinates(ctt.Id);
        }

        Test.stopTest();
    }

    @isTest
    public static void testGetContactsWithinDistance() {

        Test.startTest();

        Decimal latitude = -34.390;
        Decimal longitude = 150.650;
        Decimal distanceKm = 1000;

        Contact ctt = [SELECT Id FROM Contact WHERE FirstName = 'test' LIMIT 1];

        List<CampaignMember> cmList = HDT_LC_GeolocationCommunity.getContactsWithinDistance(latitude, longitude, distanceKm);

        System.assertEquals(ctt.Id, cmList[0].ContactId, 'getContactsWithinDistance did not work correctly');

        System.assertNotEquals(ctt.Id, 'getContactsWithinDistance did not work correctly');

        //To reach exception
        User u=[SELECT Id FROM User WHERE Email='sales@force.com' LIMIT 1];

        System.runAs(u) {
            
            cmList = HDT_LC_GeolocationCommunity.getContactsWithinDistance(latitude, longitude, distanceKm);
        }


        Test.stopTest();
    }

    @isTest
    public static void testGetLeadsWithinDistance() {

        Test.startTest();

        Decimal latitude = -34.390;
        Decimal longitude = 150.650;
        Decimal distanceKm = 1000;

        Lead ld = [SELECT Id FROM Lead WHERE Phone = '055355788' LIMIT 1];

        List<CampaignMember> cmList = HDT_LC_GeolocationCommunity.getLeadsWithinDistance(latitude, longitude, distanceKm);

        System.assertEquals(ld.Id, cmList[0].LeadId, 'getLeadsWithinDistance did not work correctly');

        System.assertNotEquals(ld.Id, 'getLeadsWithinDistance did not work correctly');

        //To reach exception
        User u=[SELECT Id FROM User WHERE Email='sales@force.com' LIMIT 1];

        System.runAs(u) {
            
            cmList = HDT_LC_GeolocationCommunity.getLeadsWithinDistance(latitude, longitude, distanceKm);
        }


        Test.stopTest();
    }

    @isTest
    public static void testUpdateContactLastLocation() {

        Test.startTest();

        Contact ctt = [SELECT Id, LastGeolocationLatitude__c, LastGeolocationLongitude__c FROM Contact WHERE Email = 'test@salesforce.com' LIMIT 1];

        Decimal latitude = -34.387;
        Decimal longitude = 150.647;

        Contact cttTest = HDT_LC_GeolocationCommunity.updateContactLastLocation(ctt.Id, latitude, longitude);

        System.assertEquals(-34.387, cttTest.LastGeolocationLatitude__c, 'Latitude Matches');

        System.assertNotEquals(cttTest.LastGeolocationLatitude__c, null, 'updateContactLastLocation did not work correctly');

        //To reach exception
        User u=[SELECT Id FROM User WHERE Email='sales@force.com' LIMIT 1];

        System.runAs(u) {
            
            cttTest = HDT_LC_GeolocationCommunity.updateContactLastLocation(ctt.Id, latitude, longitude);
        }

        Test.stopTest();
    }
}
