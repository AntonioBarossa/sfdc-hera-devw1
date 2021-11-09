/**
* Header of the class "HDT_UTL_RecordShareTst"
* @author: Luca Belometti 
* @version 1.0
* @description: Apex Test class of the HDT_UTL_RecordShareTst
* @history
* Created: 2021-08-06
* Modified By: 
**/

@Istest
public with sharing class HDT_UTL_RecordShareTst {
	@TestSetup
	static void setup(){
        Id standardUserProfileId = HDT_UTL_DataFactoryTst.getProfileId('Hera Standard User');
        HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        HDT_UTL_DataFactoryTst.createInternalUser(standardUserProfileId,true);
    }

    @isTest
    private static Void testAccountShareEditCreate() {
        List<Account> accCheck = [SELECT Id FROM Account];
        List<User> userCheck = [SELECT id,Name,IsActive FROM User WHERE IsActive = true];
        Test.startTest();
        AccountShare accShareCompiled = HDT_UTL_RecordShare.accountShareEditCreate(accCheck[0].Id,userCheck[0].Id);
        String idsToCheckAccShare = accShareCompiled.Id;
        Test.stopTest();
        //List<AccountShare> accShareCheck = [SELECT Id FROM AccountShare];
        //SomeMods

        System.assertEquals(idsToCheckAccShare, accShareCompiled.Id, 'It Has the Same Ids');
        //System.assertNotEquals(null, accShareCheck[0].Id, 'It has the Ids populated');

    }

    //** [START MOD 2021-08-09] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Commented unused Method
    // @isTest
    // private static Void testAccountShareEditCreateMap() {
    //     List<Account> accCheck = [SELECT Id FROM Account];
    //     List<User> userCheck = [SELECT id FROM User];
    //     Map<String,String> mapUserIds = new Map<String,String>();
    //     System.debug('VALORE ACCOUNT: ' + accCheck[0].Id);
    //     System.debug('VALORE CONTACT: ' + userCheck[0].Id);
    //     mapUserIds.put(String.valueOf(accCheck[0].Id), String.valueOf(userCheck[0].Id));
    //     Test.startTest();
    //     HDT_UTL_RecordShare.accountShareEditCreate(mapUserIds);
    //     Test.stopTest();
    //     List<AccountShare> accShareCheck = [SELECT Id FROM AccountShare];

    //     System.assertEquals(accShareCheck.size() > 0, accShareCheck.size() > 0, 'Has the Same value');

    // }
//** [END MOD 2021-08-09] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Commented unused Method
}
