@isTest
public with sharing class HDT_UTL_CheckCompatibilitySalesTst {
    private static HDT_UTL_Constants utlconstants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.HERA_SYSTEM_ADMINISTRATOR_NAME);
    
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;  
        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa conferma cliente','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);

           
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);
            for(Contact c : contacts) {
                c.Company__c='MMS';
            }
            insert contacts;
            Id contactId = contacts[0].id;
            Id anotherContactId = contacts[1].id;
            
            List<Order> parentOrders = HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
            Id parentOrderId = parentOrders[0].id;
            parentOrders[0].Contact__c = contactId;
            parentOrders[0].phase__c = 'In attesa conferma cliente';
            parentOrders[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
            update parentOrders;
            
            List<Order> orderss = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            orderss[0].Username__c='test';
            orderss[0].Password__c='test1';
            orderss[0].NotRegisteredMeterCase__c=true;
            orderss[0].EffectiveDate__c=date.today();
            orderss[0].PowerCommitted__c=2;
            orderss[0].ImplantType__c='13A0-Usi di Abitazione BT';
            orderss[0].RequestOption__c='Domestici-TD';
            orderss[0].CreditCheckDescription__c='test1';
            orderss[0].QualityCall__c=true;  
            orderss[0].ComfortCallDaysDue__c=null;
            orderss[0].WizardCompletedDate__c=date.today()-60;
            orderss[0].ParentOrder__c = parentOrderId;
            orderss[0].Contact__c = contactId;
            orderss[0].QualityCallUnique__c=false;
            orderss[0].AgencyCode__c='001';
            orderss[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            orderss[0].Phase__c = 'Bozza';
            insert orderss;
            
            List<Campaign> campaigns = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaigns[0].Name = 'Comfort Campaign';
            insert campaigns;
            String processName='Lead';
            MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{'HERA COMM,HCM,null,347852147,null,,Mario,Rossi,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,1,2020-10-1,Webform callback,AAA,sito standard,NO,1,2020-10-1,Webform callback,HCM,sito standard,null,,null,,2020-10-1,null,,null,,null,,null,,null,test'});
            
        } 
    }



    @isTest
    public static void generateWrapperMapTst(){
        setRequestItemListTst();
        HDT_UTL_CheckCompatibilitySales testClass =  new HDT_UTL_CheckCompatibilitySales();
      //  testClass.generateWrapperMap();
    }

    public static void setRequestItemListTst(){
        List<MassiveLoaderRequestItem__c> listReqItem = [SELECT id ,Status__c FROM MassiveLoaderRequestItem__c];

        HDT_UTL_CheckCompatibilitySales testClass =  new HDT_UTL_CheckCompatibilitySales();
        testClass.setRequestItemList(listReqItem);
    }
}