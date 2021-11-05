/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 27/09/2021
* @description HDT_BA_VasEngineSender for Test Classes
* @history Elfrida Kora – 27/09/2021 – Created class
*/


@IsTest
public class HDT_BA_VasEngineSenderTst {
    
     @TestSetup
    static void myData() 
    {
        
        
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();


        date d = Date.today().addDays(-20);
        
        Id rt =Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();   
     //Id rt=utlConstants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA;
        
        HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione Motore VAS', 'In attesa tempi di ripensamento', rt, 'HDT_RT_VAS');
         List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        Id accId = acctList[0].Id;
         List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accId);
        Id conId =  conList[0].Id;
         List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
        //Id orderId = orderList[0].Id;
        orderList[0].Contact__c = conId;
        //orderList[0].ProcessType__c = 'Comunicazione Motore VAS';
        orderList[0].Phase__c = 'In attesa tempi di ripensamento';
        orderList[0].SignedDate__c = d;
        orderList[0].RecordTypeId=rt;
        
        insert orderList;
        
        }

    @isTest
    public static void testTwo(){
                Test.startTest();
         List<Order> myOrder = [SELECT Id, Name,EffectiveDate,Status,PowerQuote__c,ValidityDateEstimate__c,Phase__c from Order];
         HDT_BA_VasEngineSender vs = new HDT_BA_VasEngineSender();
         Database.executeBatch(vs);
                Test.stopTest();
         List<Order> myUpOrd = [SELECT Id, Name,EffectiveDate,Status,PowerQuote__c,ValidityDateEstimate__c,Phase__c from Order];

      System.assertEquals(true, myUpOrd[0].Phase__c!=myOrder[0].Phase__c,'This field has been updated');
     
    }
}