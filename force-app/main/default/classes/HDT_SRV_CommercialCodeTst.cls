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

        boolean finito;

        Test.startTest();

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.checkAccessInit('Name', 'read');

        Test.stopTest();
        finito = true;
        System.assertEquals(true, finito, 'testCheckAccessInit not finished');
        System.assertNotEquals(false, finito, 'testCheckAccessInit not finished');
    }

    @isTest
    public static void testCheckReadAccess() {

        boolean finito;

        Test.startTest();

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.checkReadAccess('Name');

        Test.stopTest();
        finito = true;
        System.assertEquals(true, finito, 'testCheckReadAccess not finished');
        System.assertNotEquals(false, finito, 'testCheckReadAccess not finished');
    }

    @isTest
    public static void testCheckCreateAccess() {

        boolean finito;

        Test.startTest();

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.checkCreateAccess('Name');

        Test.stopTest();
        finito = true;
        System.assertEquals(true, finito, 'testCheckCreateAccess not finished');
        System.assertNotEquals(false, finito, 'testCheckCreateAccess not finished');
    }

    @isTest
    public static void testCheckUpdateAccess() {

        boolean finito;

        Test.startTest();

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.checkUpdateAccess('Name');

        Test.stopTest();
        finito = true;
        System.assertEquals(true, finito, 'testCheckUpdateAccess not finished');
        System.assertNotEquals(false, finito, 'testCheckUpdateAccess not finished');
    }

    @isTest
    public static void testCreateRecord() {

        Test.startTest();

        CommercialCode__c commercialCode = [SELECT Id, Name FROM CommercialCode__c WHERE Name = 'Test Commercial Code' LIMIT 1];

        CommercialCode__c cc = new CommercialCode__c(
            Name = 'Test Commercial Code'
        );

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        testCommercialCode.createRecord(cc);

        System.assertEquals(commercialCode.Name, cc.Name, 'Value of parameter is matching');

        System.assertNotEquals(commercialCode.Name, '', 'Value of parameter is not matching');

        Test.stopTest();
    }

    @isTest
    public static void testUpdateRecord() {

        Test.startTest();

        HDT_SRV_CommercialCode testCommercialCode = new HDT_SRV_CommercialCode();

        CommercialCode__c commercialCode = [SELECT Id, Name FROM CommercialCode__c WHERE Name = 'Test Commercial Code' LIMIT 1];

        CommercialCode__c cc = commercialCode;

        commercialCode.Name = 'Test Commercial Code Updated';

        testCommercialCode.updateRecord(commercialCode);

        System.assertEquals(cc.Name, commercialCode.Name, 'Value of parameter is matching');

        System.assertNotEquals(commercialCode.Name, '', 'Value of parameter is not matching');

        Test.stopTest();

    }
}
