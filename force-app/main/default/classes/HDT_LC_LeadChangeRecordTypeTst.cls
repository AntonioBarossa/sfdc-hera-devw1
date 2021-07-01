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
        
        HDT_UTL_DataFactoryTst.createLead();
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

        //List<Case> lstCases =[SELECT Id, RecordType.Name, Subject, Type FROM Case];

        //Debug to check if 'lstCases' values are correct
        //System.debug('lstCases = ' +lstCases);

        // System.assertEquals(1, lstCases.size(), 'Case not created');
        // System.assertEquals('Modifica Privacy', lstCases[0].Type);

        // System.debug(lstCases[0].Type);
        // System.assertNotEquals('', lstCases[0].Type);

        System.assertEquals('', str, 'URL not populated correctly');

        System.assertNotEquals('https://', str);

        Test.stopTest();
    }
}
