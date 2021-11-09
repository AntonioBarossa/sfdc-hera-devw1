/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 03/08/2021
 * @description HDT_QR_FileTemplate Test Class
 * @history Lucas da Silva Fernandes - 03/08/2021 - Class creation
 */

@isTest
public with sharing class HDT_QR_FileTemplateTst {

    @TestSetup
    static void setup(){

        List<FileTemplate__c> ftList = HDT_UTL_DataFactoryTst.createFileTemplate(1, true);

        HDT_UTL_DataFactoryTst.createFileTemplateColumn(1, true, ftList[0].Id);
        
    }

    @isTest
    public static void testGetRecordByTemplateName() {

        Test.startTest();

        List<FileTemplate__c> ft = new List<FileTemplate__c>();

        HDT_QR_FileTemplate qrFt = new HDT_QR_FileTemplate();

        ft = qrft.getRecordByTemplateName('Test File Template Api');

        System.assertEquals('CSV', ft[0].FileType__c, 'File Template Type matches.');

        System.assertNotEquals('CSV', null, 'File Template Type does not match.');

        Test.stopTest();
    }
}
