/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 12/10/2021
* @description Test Class for  HDT_TRH_ServicePoint
*/
@isTest
public with sharing class HDT_TRH_ServicePointTst {
    @testSetup
    static void setup() {
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servPointList[0].CommoditySector__c = 'Energia Elettrica';
        servPointList[0].SupplyType__c = 'Domestico';
        servPointList[0].ImplantType__c = '13A0-Usi di Abitazione BT';

        insert servPointList;
    }

    @isTest
    public static void testBeforeUpdate() {

        Test.startTest();

        ServicePoint__c sp = [SELECT Id, Name, SupplyType__c, ImplantType__c FROM ServicePoint__c WHERE Name = 'testServicePoint0' LIMIT 1];
        sp.SupplyType__c = null;
        sp.ImplantType__c = null;
        update sp;

        ServicePoint__c updatedSp = [SELECT Id, Name, SupplyType__c, ImplantType__c FROM ServicePoint__c WHERE Name = 'testServicePoint0' LIMIT 1];        

        Test.stopTest();

        System.assertEquals('Domestico', updatedSp.SupplyType__c, 'The incorrect Supply Type is present on the Service Point');
        System.assertEquals('13A0-Usi di Abitazione BT', updatedSp.ImplantType__c, 'The incorrect Implant Type is present on the Service Point');
    }
}
