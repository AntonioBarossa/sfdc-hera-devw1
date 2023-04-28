/**
    * @author Angelo Ballacchino (angelo.ballacchino@nttdata.com)
    * @date 20/04/2023
    */
@isTest
public class HDT_UTL_SlaTrackingTst {

    @TestSetup
    static void makeData(){
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
        List<Case> caseList=HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, orders[0].id);
        Map<String,Object> slaAdminFields=new Map<String,Object>{
            'Ato__c'=>'ATO Orientale Triestino','IsActive__c'=>true,
            'CaseField__c'=>'CustomerRequestDate__c','OrderField__c'=>'SendCertifiedEmailConsentDate__c',
            'FirstLevelComplaintClassification__c'=>'Reclamo Scritto','SecondLevelComplaintClassification__c'=>'Mercato','Cluster__c'=>'Attivazioni',
            'Description__c'=>'test','StartCasePhase__c'=>'Bozza','EndCasePhase__c'=>'Comunicazione verso Heroku OK',
            'StartOrderPhase__c'=>'Bozza','EndOrderPhase__c'=>'Comunicazione verso Heroku OK','Range__c'=>15,
            'Process__c'=>'Documentale/Copia Contratto','RecordTypeId'=>Schema.SObjectType.SlaAdministration__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_PostSales').getRecordTypeId(),
            'Commodity__c'=>'Acqua','SalesCompany__c'=>'Hera Comm S.p.A.','ActivityType__c'=>'Back Office - Fatturazione',
            'CustomerType__c'=>'Account','RangeType__c'=>'Giorni Solari','Type__c'=>'01'
        };
        List<SlaAdministration__c> slaAdminRules=HDT_UTL_DataFactoryTst.createSlaAdministration(1,true,slaAdminFields);
        HDT_UTL_DataFactoryTst.createSlaTracking(1,true,null, slaAdminRules[0].Id, caseList[0].Id, null, 100, 'Aperto');
        HDT_UTL_DataFactoryTst.createSlaTracking(1,true,null, slaAdminRules[0].Id, null, orders[0].Id, 100, 'Aperto');
    }

   

  @isTest
	private static void testCalculateSlaRealValue() {
    // Create test data
    SlaAdministration__c slaAdmin = new SlaAdministration__c(RangeType__c = 'Giorni Lavorativi', Range__c = 5); // Define a dummy SLA administration rule
    insert slaAdmin;

    SlaTracking__c slaTrack = new SlaTracking__c(SlaAdministration__c = slaAdmin.Id, StartDateTime__c = DateTime.newInstance(2023, 4, 18, 10, 0, 0)); // Define a dummy SLA tracking record
    insert slaTrack;

    slaTrack.EndDateTime__c = DateTime.newInstance(2023, 4, 23, 12, 0, 0);
    update slaTrack;
        
    Test.startTest();

    // Call the method to be tested
    HDT_UTL_SlaTracking.calculateSlaRealValue(new List<SlaTracking__c>{slaTrack});

    Test.stopTest();

    // Verify the result
    slaTrack = [SELECT SlaValue__c FROM SlaTracking__c WHERE Id = :slaTrack.Id];
    System.assertEquals(6, slaTrack.SlaValue__c); 
}

   
    
    
    
    @isTest
private static void testCalculateSlaForecastValue() {
    // Create test data
    List<SlaTracking__c> slaTrackingToElaborate = [SELECT Id FROM SlaTracking__c LIMIT 1];
    
    
    //SlaAdministration__c slaAdmin = new SlaAdministration__c(Range__c = 5);
    //insert slaAdmin;
	SlaAdministration__c slaAdmin = [SELECT Id,Range__c FROM SlaAdministration__c LIMIT 1];
    SlaTracking__c slaTrack = new SlaTracking__c(SlaAdministration__c = slaAdmin.Id, StartDateTime__c = DateTime.newInstance(2023, 4, 18, 10, 0, 0)); 
    insert slaTrack;
    

	

    Test.startTest();

    // Call the method to be tested
   	HDT_UTL_SlaTracking.calculateSlaForecastValue(new List<SlaTracking__c>{slaTrack});
    
	

    Test.stopTest();

    // Verify the result
    slaTrack = [SELECT EndDateSolarDays__c, EndDateWorkingDays__c FROM SlaTracking__c WHERE Id = :slaTrack.Id];
    Date assertDate = Date.newInstance(2023, 4, 18).addDays(Integer.valueOf(slaAdmin.Range__c));
    System.assertEquals(assertDate, slaTrack.EndDateSolarDays__c); // Expecting 5 solar days (Mon to Fri)
   
}
    
    
    
    
    
    
    @isTest
private static void testCalculateWorkingDays() {
    
    Date startDate = Date.newInstance(2023, 4, 18); 
    Integer slaRange = 5;
    List<TechnicalHolidaysCalendar__c> holidayList = new List<TechnicalHolidaysCalendar__c>{
        new TechnicalHolidaysCalendar__c(HolidayDate__c = Date.newInstance(2023, 4, 19)), 
        new TechnicalHolidaysCalendar__c(HolidayDate__c = Date.newInstance(2023, 4, 20)) 
    };

    Test.startTest();

   
    Date result = HDT_UTL_SlaTracking.calculateWorkingDays(startDate, slaRange, holidayList);

    Test.stopTest();

}
    
    @isTest
private static void testConvertDateTime() {
    // Create test data
    DateTime dt = DateTime.newInstance(2023, 4, 18, 12, 30, 0);

    // Call the method to be tested
    Date result = HDT_UTL_SlaTracking.convertDateTime(dt);

    // Verify the result
    System.assertEquals(Date.newInstance(2023, 4, 18), result);
}
    
    @isTest
private static void testCalculateWorkingDaysInteger() {
    // Create test data
    Date startDate = Date.newInstance(2023, 4, 18); 
    Integer diff = 5;
    List<TechnicalHolidaysCalendar__c> holidayList = new List<TechnicalHolidaysCalendar__c>{
        new TechnicalHolidaysCalendar__c(HolidayDate__c = Date.newInstance(2023, 4, 19)), 
        new TechnicalHolidaysCalendar__c(HolidayDate__c = Date.newInstance(2023, 4, 20))  
    };

    Test.startTest();

    // Call the method to be tested
    Integer result = HDT_UTL_SlaTracking.calculateWorkingDaysInteger(startDate, diff, holidayList);

    Test.stopTest();

    // Verify the result
    System.assertEquals(2, result);
}
    
    
    
    @isTest
private static void testCalculateSlaValue() {
    // Create test data
    DateTime startDatetime = DateTime.newInstance(2023, 4, 18, 10, 0, 0); // 10:00 AM
    DateTime endDatetime = DateTime.newInstance(2023, 4, 20, 15, 30, 0); // 3:30 PM

    Test.startTest();

    // Call the method to be tested
    Integer result = HDT_UTL_SlaTracking.calculateSlaValue(startDatetime, endDatetime);

    Test.stopTest();

    // Verify the result
    System.assertEquals(3, result); // Expecting 3 days (Mon, Tue, Wed)
}
    
    

}