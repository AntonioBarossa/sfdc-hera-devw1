/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 24/06/2021
* @description Test Class for HDT_LC_LeadChangeRecordType.cls
* @history Lucas da Silva Fernandes – 24/06/2021 – Created class
*/

@isTest
public class HDT_LC_LeadChangeRecordTypeTst{

	@TestSetup
	static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        
        HDT_UTL_DataFactoryTst.createLead(1, true);
    }
    
    @isTest
	static void testChangeRecordTypeOfLead () {

        Test.startTest();

        RecordType rt = [SELECT Id 
                        FROM RecordType 
                        WHERE DeveloperName = 'HDT_RT_Main' and SobjectType = 'Lead' 
                        LIMIT 1];

        Lead updateLead = [SELECT id, LastName 
                          FROM Lead
                          WHERE LastName = 'LastNameTest'
                          LIMIT 1];
        
        updateLead.RecordTypeId = rt.Id;

        String str = HDT_LC_LeadChangeRecordType.changeRecordTypeOfLead(updateLead.Id);

        update updateLead;

        System.assertEquals('', str, 'URL not populated correctly');

        System.assertNotEquals('https://', str);

        Test.stopTest();
    }
}
