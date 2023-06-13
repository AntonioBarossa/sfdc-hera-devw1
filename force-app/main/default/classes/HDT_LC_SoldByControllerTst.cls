@IsTest
public with sharing class HDT_LC_SoldByControllerTst {
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende Soho');
        Id accId = accs[0].id;
        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(16, false, accId, 'Attiva');
        sales[0].Channel__c = 'Sportello';
        sales[0].Agency__c = 'AG001';
        sales[0].AgencyCode__c = 'AG01T025';
        sales[0].VendorLastName__c = 'Rossi';
        sales[0].VendorFirstName__c = 'Mario';
        sales[0].CommercialId__c = '123456';
        sales[0].UpperChannelAgency__c = 'AC';
        sales[0].LowerChannelAgency__c = 'LW';
        sales[0].AreaManager__c = 'Test AreaManager';
        insert sales;
        List<Order> parentOrders = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
        parentOrders[0].Sale__c = sales[0].Id;
        List<Order> childOrders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, accId, sales, Test.getStandardPricebookId());
        childOrders[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
        childOrders[0].ParentOrder__c = parentOrders[0].Id;
        childOrders[0].Sale__c = sales[0].Id;
        childOrders.add(parentOrders[0]);
        insert childOrders;
    }

    @IsTest
    public static void testGetSaleChannel(){
        Sale__c sale = [SELECT id FROM Sale__c LIMIT 1][0];
        Test.startTest();
            System.assertEquals(HDT_LC_SoldByController.getSaleChannel(sale.Id), 'Sportello', 'Non è stato restituito il canale corretto');
            delete sale;
            Boolean exc = false;
            try {
                HDT_LC_SoldByController.getSaleChannel(sale.Id);
            } catch (Exception e) {
                exc = true;
            }
            System.assertEquals(exc, true, 'Non è stata lanciata l\'eccezione');
        Test.stopTest();
    }

    @IsTest
    public static void testUpdateAllOrder(){
        Id saleid = [SELECT id FROM Sale__c LIMIT 1][0].Id;
        Sale__c sale = new Sale__c(Id = saleId);
        sale.Agency__c = 'AG002';
        sale.AgencyCode__c = 'AG01T035';
        sale.VendorLastName__c = 'Verdi';
        sale.VendorFirstName__c = 'Giuseppe';
        sale.CommercialId__c = '654321';
        Test.startTest();
            HDT_LC_SoldByController.updateAllOrder(sale);
            for(Order o : [SELECT id,Agency__c,AgencyCode__c,VendorLastName__c,VendorFirstName__c,CommercialId__c,UpperChannelAgency__c,LowerChannelAgency__c,AreaManager__c FROM Order WHERE Sale__c = :sale.Id]){
                System.assertEquals(o.Agency__c, 'AG002', 'Agenzia errata');
                System.assertEquals(o.AgencyCode__c, 'AG01T035', 'Codice Agenzia Errato');
                System.assertEquals(o.VendorLastName__c, 'Verdi', 'Cognome Errato');
                System.assertEquals(o.VendorFirstName__c, 'Giuseppe', 'Nome Errato');
                System.assertEquals(o.CommercialId__c, '654321', 'Codice Venditore Errato');
                System.assert(String.isBlank(o.UpperChannelAgency__c), 'Upper Channel Agency non corretto');
                System.assert(String.isBlank(o.LowerChannelAgency__c), 'Lower Channel Agency non corretto');
                System.assert(String.isBlank(o.AreaManager__c), 'Area manager non corretta');
            }
        Test.stopTest();
    }

}