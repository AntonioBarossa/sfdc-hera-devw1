/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 12/07/2021
* @description HDT_LC_CalculateEstimatedCost for Test Classes
* @history Luca Belometti WR (luca.belometti@webresults.it) – 03/08/2021 – Added Test Methods
*/

@isTest
public with sharing class HDT_LC_CalculateEstimatedCostTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @testSetup
        static void setup(){
            
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            /*
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            points[0].Distributor__c = acc[0].id;
            insert points; */

            List<ServicePoint__c> servPointList=new List<ServicePoint__c>();
            ServicePoint__c servPoint=new ServicePoint__c();
            //servPoint.Distributor__c = acc[0].id;
            servPoint.Name='testServicePoint';
            servPoint.ServicePointCode__c='testServicePointCode';
            servPoint.RecordTypeId = constants.SERVICEPOINT_RECORDTYPEID_PELETRICCO;
            servPointList.add(servPoint);
            insert servPointList;
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, acc[0].Id, 'Bozza');
            orders[0].ServicePoint__c = servPointList[0].id;
            orders[0].RecordTypeId = constants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT;
            orders[0].SupplyType__c = 'Domestico';
            orders[0].PowerRequested__c = 1.1;
            orders[0].PowerAvailable__c = 1.5;
            insert orders;

        }

    @isTest
    public static void testUpdateOrder(){
        Test.startTest();
        
        Order updateOrder = [SELECT id, Status, EstimateAmount__c, PowerQuote__c, AdministrativeBurden__c, EstimatedVAT__c, ValidityDateEstimate__c, Phase__c, OperationCode__c, QuotationType__c
                            FROM Order
                            WHERE Status = 'Draft'
                            LIMIT 1];

        HDT_LC_CalculateEstimatedCost.updateOrder(updateOrder);

        
        System.assertEquals(1000.00, updateOrder.EstimateAmount__c, 'EstimateAmount__c not correct!');
        System.assertNotEquals(2000.00, updateOrder.EstimateAmount__c, 'updateOrder did not work correctly');

        Test.stopTest();
    }
    
//** [START MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Added this Test Method

/**
* Header of the method "testGetExtimatedCost"
* @author: Luca Belometti - WR (luca.belometti@webresults.it)
* @version 1.0
* @description: 
* @history
* Created: 2021-08-03
* Modified By:
**/    
    @isTest
    public static void testGetExtimatedCost(){
        Test.startTest();
        
        Order updateOrder = [SELECT id, Status, EstimateAmount__c, PowerQuote__c, AdministrativeBurden__c, EstimatedVAT__c, ValidityDateEstimate__c, 
                             Phase__c, RecordTypeId, recordType.DeveloperName, PowerRequested__c, PowerAvailable__c, VoltageLevel__c, PowerCommitted__c,
                             UseTypeEnergy__c, ServicePoint__r.Distributor__r.Name, RequestPhase__c, ConnectionType__c, ProcessCode__c
                            FROM Order
                            WHERE Status = 'Draft'
                            LIMIT 1];

    HDT_LC_CalculateEstimatedCost.getExtimatedCost(updateOrder);

    
    System.assertEquals(1000.00, updateOrder.EstimateAmount__c, 'EstimateAmount__c not correct!');
    System.assertNotEquals(2000.00, updateOrder.EstimateAmount__c, 'getExtimatedCost did not work correctly');

    Test.stopTest();
}
//** [END MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Added this Test Method
//** [START MOD 21/10/2021] @Author:Cesare Bagnolini WR (cesare.bagnolini@webresults.it) @Description: Added this Test Method
    @isTest 
    public static void testGetFixedQuotes(){
        
        Order updateOrder = [SELECT id, Status, EstimateAmount__c, PowerQuote__c, AdministrativeBurden__c, EstimatedVAT__c, ValidityDateEstimate__c, 
                             Phase__c, RecordTypeId, recordType.DeveloperName, PowerRequested__c, PowerAvailable__c, VoltageLevel__c, PowerCommitted__c,
                             UseTypeEnergy__c, ServicePoint__r.Distributor__r.Name, RequestPhase__c, ConnectionType__c, ProcessCode__c, SupplyType__c
                             FROM Order
                             WHERE Status = 'Draft'
                             LIMIT 1];

        HDT_LC_CalculateEstimatedCost.HDT_WRP_ExtimatedCost ext = new HDT_LC_CalculateEstimatedCost.HDT_WRP_ExtimatedCost();
        ext.fixedQuotes = new HDT_CalcoloPreventivi__mdt();
        /*
        fixedQuotes.VAT__c >> 10.00
        fixedQuotes.DistributorFixedQuote__c >> 0.00
        fixedQuotes.PowerQuote__c >> 56.16
        fixedQuotes.SellerFixedQuote__c >> 23.00
        fixedQuotes.Type__c >> 'Domestico'
        variableAmount >> -16.2864 
        estimatedAmount >> 7.384960
        estimatedAmount = estimatedAmount.setScale(2) >> 7.38
        */

        Test.startTest();
        
        HDT_LC_CalculateEstimatedCost.getFixedQuotes(updateOrder, ext);
        HDT_LC_CalculateEstimatedCost.getExtimatedCost(updateOrder);
        
        Test.stopTest();
        
        System.assertEquals(7.38, ext.estimatedAmount, 'EstimateAmount__c not correct!');
        System.assertEquals(1000.00, updateOrder.EstimateAmount__c, 'EstimateAmount__c not correct!');
        System.assertNotEquals(2000.00, updateOrder.EstimateAmount__c, 'EstimateAmount__c not correct!');
        
    }
//** [END MOD 21/10/2021] @Author:Cesare Bagnolini WR (cesare.bagnolini@webresults.it) @Description: Added this Test Method
}