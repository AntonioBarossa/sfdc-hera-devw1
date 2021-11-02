/**
* @author Fabricio Nunes (fabricio.nunes@engdb.com.br)
* @date 19/07/2021
* @description HDT_LC_ResumeCommercialBonus Test Class
* @history Fabricio Nunes – 19/07/2021 – Created class
*/

@isTest
public with sharing class HDT_LC_ResumeCommercialBonusTst {

@testSetup
    static void setup(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList;
        caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }

@isTest
public static void testLoadCase(){
    Test.startTest();
    
    Case tCase = [SELECT Id, Status, Phase__c, type FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];

    Map<String, Object> tCaseMap = HDT_LC_ResumeCommercialBonus.loadCase(tcase.Id);

    System.debug('tCaseMap = '+tCaseMap);

    List<Case> cList = new List<Case>();
    cList.add(tCase);

    
    System.assertEquals(tCase, tCaseMap.get('case'), 'Method return is not correct!');

    System.assertNotEquals(null, tCaseMap.get('case'), 'loadCase did not work correctly');

    Test.stopTest();
}
}