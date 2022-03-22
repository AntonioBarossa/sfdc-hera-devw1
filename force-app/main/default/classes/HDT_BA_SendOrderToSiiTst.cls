/*Author: Edoardo Zanatta
* Date: 18/01/2022
* Test Class for HDT_BA_SendOrderToSii and HDT_SCH_SendOrderToSii
*/

@isTest
public class HDT_BA_SendOrderToSiiTst {

    @TestSetup
    static void makeData(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        HDT_UTL_DataFactoryTst.createOrder(10, true, accList[0].Id, 'Bozza');
    }

    @isTest
    static void test(){

        Date tday = System.today();
        List<Order> orderListTest = [SELECT Id, Phase__c, DateSentToSii__c FROM Order];

        for(Order ord : orderListTest){
            ord.DateSentToSii__c = tday;
            ord.Phase__c = 'In attesa tempi di ripensamento';
        }

        update orderListTest;


        /*
        DateTime now = Datetime.now();
        now.addMinutes(2);
        String hour = String.valueOf(now.hour());
        String min = String.valueOf(now.minute());
        String ss = String.valueOf(now.second());

        String fireTime = ss + ' ' + min + ' ' + hour + ' * * ? '+now.year();*/

        Test.startTest();

        HDT_BA_SendOrderToSii testing = new HDT_BA_SendOrderToSii();
        Database.executeBatch(testing);

        Test.stopTest();

        for(Order ts : [SELECT id, Phase__c FROM Order]){
            System.assertEquals(ts.Phase__c, 'Comunicazione verso Heroku', 'Success');
        }
    }
}