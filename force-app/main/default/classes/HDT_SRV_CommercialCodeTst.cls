/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 27/07/2021
 * @description HDT_SRV_CommercialCodeTst
 * @history Lucas da Silva Fernandes – 27/07/2021
 */

@isTest
public with sharing class HDT_SRV_CommercialCodeTst {
    
    @TestSetup
    static void setup(){
        
        CommercialCode__c cc = new CommercialCode__c();

        cc.Name = 'Test Commercial Code';

        insert cc;
    }

    @isTest
    public static void testCheckAccessInit() {

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.checkAccessInit('Name', 'read');
    }

    @isTest
    public static void testCheckReadAccess() {

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.checkReadAccess('Name');
    }

    @isTest
    public static void testCheckCreateAccess() {

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.checkCreateAccess('Name');
    }

    @isTest
    public static void testCheckUpdateAccess() {

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.checkUpdateAccess('Name');
    }

    @isTest
    public static void testCreateRecord() {

        CommercialCode__c commercialCode = [SELECT Id, Name FROM CommercialCode__c WHERE Name = 'Test Commercial Code' LIMIT 1];

        CommercialCode__c cc = new CommercialCode__c(
            Name = 'Test Commercial Code'
        );

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.createRecord(cc);

        System.assertEquals(commercialCode.Name, cc.Name);

        System.assertNotEquals(commercialCode.Name, '');
    }

    @isTest
    public static void testUpdateRecord() {

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        CommercialCode__c commercialCode = [SELECT Id, Name FROM CommercialCode__c WHERE Name = 'Test Commercial Code' LIMIT 1];

        CommercialCode__c cc = commercialCode;

        commercialCode.Name = 'Test Commercial Code Updated';

        testCommercialCode.updateRecord(commercialCode);

        System.assertEquals(cc.Name, commercialCode.Name);

        System.assertNotEquals(commercialCode.Name, '');

    }
}
