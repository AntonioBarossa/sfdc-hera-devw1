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
                          WHERE LastName = 'LastNameTest0'
                          LIMIT 1];
        
        updateLead.RecordTypeId = rt.Id;

        Map<String,String> mapp = HDT_LC_LeadChangeRecordType.changeRecordTypeOfLead(updateLead.Id);

        System.assertEquals('false', mapp.get('isCommunity'), 'URL not populated correctly');

        System.assertNotEquals(null, mapp, 'value of parameter is not matching');

        Test.stopTest();
    }
}