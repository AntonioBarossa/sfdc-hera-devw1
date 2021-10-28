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
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            points[0].Distributor__c = acc[0].id;
            insert points;
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, acc[0].Id, 'Bozza');
            orders[0].ServicePoint__c = points[0].id;
            orders[0].RecordTypeId = constants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT;
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

        System.assertNotEquals(2000.00, updateOrder.EstimateAmount__c);

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

        System.assertNotEquals(2000.00, updateOrder.EstimateAmount__c);

        Test.stopTest();
    }
//** [END MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Added this Test Method
//** [START MOD 21/10/2021] @Author:Cesare Bagnolini WR (cesare.bagnolini@webresults.it) @Description: Added this Test Method
    @isTest static void testGetFixedQuotes(){
        
        Order updateOrder = [SELECT id, Status, EstimateAmount__c, PowerQuote__c, AdministrativeBurden__c, EstimatedVAT__c, ValidityDateEstimate__c, 
                             Phase__c, RecordTypeId, recordType.DeveloperName, PowerRequested__c, PowerAvailable__c, VoltageLevel__c, PowerCommitted__c,
                             UseTypeEnergy__c, ServicePoint__r.Distributor__r.Name, RequestPhase__c, ConnectionType__c, ProcessCode__c, SupplyType__c
                             FROM Order
                             WHERE Status = 'Draft'
                             LIMIT 1];
        
        HDT_LC_CalculateEstimatedCost.HDT_WRP_ExtimatedCost ext = new HDT_LC_CalculateEstimatedCost.HDT_WRP_ExtimatedCost();
        ext.fixedQuotes = new HDT_CalcoloPreventivi__mdt();
        ext.validityDate = 'yes';
        ext.estimatedAmount = 1.1;
        
        Test.startTest();
        
        HDT_LC_CalculateEstimatedCost.getFixedQuotes(updateOrder, ext);
        HDT_LC_CalculateEstimatedCost.getExtimatedCost(updateOrder);
        
        Test.stopTest();
               
        System.assertEquals(1000.00, updateOrder.EstimateAmount__c, 'EstimateAmount__c not correct!');

        System.assertNotEquals(2000.00, updateOrder.EstimateAmount__c, 'EstimateAmount__c not correct!');
        
    }
//** [END MOD 21/10/2021] @Author:Cesare Bagnolini WR (cesare.bagnolini@webresults.it) @Description: Added this Test Method
}