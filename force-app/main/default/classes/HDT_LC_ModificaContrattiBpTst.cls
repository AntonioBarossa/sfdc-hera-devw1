/**
 * @author Valere (valere@noeli-it.net)
 * @date 21/10/2021
 * @description HDT_LC_ModificaContrattiBp Test Classes
 * @history valere - 21/10/2021– Created Class
 */
@istest
public class HDT_LC_ModificaContrattiBpTst {

    @TestSetup
    static void makeData(){
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM','Persona fisica','Famiglie');
        HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accountList[0].id);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact (1,true,accountList[0].id); 
        List<ServicePoint__c> servicepointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accountList[0].id);
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].id, 'Bozza');
        HDT_UTL_DataFactoryTst.createCase(2, true, accountList[0].id, contactList[0].id, servicepointList[0].id, contractList[0].id, orderList[0].id);        
    }

    @IsTest
    static void testUpdateBpDataOnCase(){
    List<Case> caseList = [SELECT Id, ContactId, AccountId, AssetId, SourceId, BusinessHoursId, ParentId, RecordTypeId, OwnerId, CreatedById, LastModifiedById, ExistingInstallmentPlanUnpaid__c, PaidAmount__c, Resident__c, ComparePaidToPay__c, ResidenceChangeDate__c, ClientIdentificationDate__c, AlternativeAddress__c, RowIdSiebel__c, QuotationValidityDate__c, TotalResidue__c, TotalPaidCustomer__c, TotalPaidCustomerToPay__c, DocumentResidue__c, ServiceRequestID__c, PowerReductionDate__c, PraxidiaAccuracyandCompleteness__c, PraxidiaClarityValue__c, PraxidiaClarityandUnderstanding__c, PraxidiaCourtesyValue__c, PraxidiaDateOutcome__c, PraxidiaDissatisfiedCustomer__c, PraxidiaFCR__c, PraxidiaNPS__c, PraxidiaNote__c, PraxidiaOverrallSatisfaction__c, PraxidiaResolutionNeed__c, PraxidiaSatisfactionRequired__c, PraxidiaTimeliness__c, PraxidiaVerbatim__c, PraxidiaWaitValue__c, BillingCityCode__c, BillingCity__c, BillingCountry__c, BillingIsAddressVerified__c, BillingPlace__c, BillingPostalCode__c, BillingProvince__c, BillingStreetCode__c, BillingStreetName__c, BillingStreetNumberExtension__c, BillingStreetNumber__c, BillingStreetToponym__c, IntegrationId__c, EndValidityDate__c, PraxidiaResolution__c FROM case];
    Map<String, Object> bpData = new Map<string, Object>{
        'Zero'=>caseList[0],
        'First'=>caseList[1]};     
        Test.startTest();
        try {
            HDT_LC_ModificaContrattiBp.updateBpDataOnCase (bpData, caseList[0].id);
        }catch(exception e){
            System.assertEquals('Script-thrown exception',e.getMessage(),'HDT_SRV_Case was not updated because fieldsNotMapped is not empty');
            System.assertNotEquals(false,'Script-thrown exception'==e.getMessage(),'The error is due to the fact that bad fields have been provided');
        }        
        Test.stopTest();
    }

    @IsTest
    static void testfilterDataToBp(){
    List<Case> caseList = [SELECT Id, ContactId, AccountId, BillingCityCode__c, BillingCity__c, BillingCountry__c FROM case];
    Map<String, Object> bpData = new Map<string, Object>{
        'account__c'=>caseList[0],
        'accountclass__c'=>caseList[1]};  
        system.debug('bpData '+bpData.keyset());           
        Test.startTest();
            Map<String, Object> response = HDT_LC_ModificaContrattiBp.filterDataToBp (bpData);
        Test.stopTest();
        System.assertEquals(true, JSON.serialize(response.get('account__c')).Contains(caseList[0].ContactId), 'The Map is well formed');
        System.assertNotEquals(false, JSON.serialize(response.get('account__c')).Contains(caseList[0].ContactId), 'The response has been well provided with case list contact ids');
    
    }

}