/**
 * Header of the class "HDT_BA_AttributesContactTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_BA_AttributesContact"
 * @history
 * @Created 21/09/2021
 * Modified By:
 **/

@isTest
public class HDT_BA_AttributesContactTst {
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            Integer i=0;
            
            List<Individual> inds = HDT_UTL_DataFactoryTst.createIndividual(2,false);
    
            
            for(Individual ind : inds){
                ind.PrivacyProfilingChoiceDate__c=System.today()+i;
                ind.ProfilingPrivacy__c='SI';
                i++;
            }
            insert inds;
        
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(50,false,accId);
            
            i=0;
            for(Contact c : contacts){
                c.Email='email@'+i+'.it';
                c.Company__c='MMS';
                c.IndividualId=inds[0].Id;
                i++;
            }
            insert contacts;
            
            List<Contact> contactsDuplicate = HDT_UTL_DataFactoryTst.createContact(50,false,accId);
            
            i=0;
            for(Contact c : contactsDuplicate){
                c.FirstName='test2'+i;
                c.LastName='tester2'+i;
                c.Email='email@'+i+'.it';
                c.Company__c='MMS';
                c.IndividualId=inds[0].Id;
                i++;
            }
            insert contactsDuplicate;
            
            
            
            List<BillingProfile__c> billings = HDT_UTL_DataFactoryTst.createBillingProfile(50,false,accId);
            
            i=0;
            for(BillingProfile__c b : billings){
                b.Contact__c=contactsDuplicate[i].id;
                b.BillSendingMethod__c='Cartaceo';
                b.PaymentMethod__c='RID';
                b.Status__c='Attivo';
                i++;
            }
            insert billings;
            
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(50,false,accId,'Bozza');
            
            i=0;
            for(Order o : orders){
                o.Contact__c=contactsDuplicate[i].id;
            }
            insert orders;
            
            
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(50,false,accId);
            
            i=0;
            for(Contract contr : contracts){
                contr.Contact__c=contactsDuplicate[i].id;
                contr.SAPContractCode__c='30119134'+i;
                i++;
            }
            insert contracts;
            
            HDT_UTL_DataFactoryTst.createCase(50,true,accId,contactsDuplicate[0].id,null,contracts[0].id,orders[0].id);
            
                
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CampagenDmDmpData','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser'); 
        }
    }
    
    @isTest
    static void testMail(){
        
        Integer varFileNumber = 0;
        String paramRunId = 'someid';
        String paramStatus = '';
        String paramErrorMessage = 'Simple param error message';
        List<id> paramListIdContentVersion = new List<Id>();
        
        Set<String> paramSetEmailProcessed = new Set<String>();
        paramSetEmailProcessed.add('email@0.it');
        
        Test.startTest();
		HDT_BA_AttributesContact ac = new HDT_BA_AttributesContact(varFileNumber,paramRunId,paramStatus,paramErrorMessage,paramListIdContentVersion,paramSetEmailProcessed);
        ac.setEmailContactProcessed = new Set<String>();
        ac.setEmailContactProcessed.add('email@0.it');
        Database.executeBatch(ac,200);
        Test.stopTest();
        
        List <ContentVersion> lista = [Select id from ContentVersion where Title LIKE 'heradmp_firstpartydata_%'];
        System.assertEquals(false, lista.isEmpty(),'AttributesContact did not execute correctly');
    }
    
    @isTest
    static void testNull(){
        
        Integer varFileNumber = 0;
        String paramRunId = 'someid';
        String paramStatus = '';
        String paramErrorMessage = 'Simple param error message';
        List<id> paramListIdContentVersion = new List<Id>();
        
        Set<String> paramSetEmailProcessed = new Set<String>();
        
        Test.startTest();
		HDT_BA_AttributesContact ac = new HDT_BA_AttributesContact(varFileNumber,paramRunId,paramStatus,paramErrorMessage,paramListIdContentVersion,paramSetEmailProcessed);
        Database.executeBatch(ac,200);
        Test.stopTest();
        
        List <ContentVersion> lista = [Select id from ContentVersion where Title LIKE 'heradmp_firstpartydata_%'];
        System.assertEquals(false, lista.isEmpty(),'AttributesContact did not execute correctly');
    }
    
    @isTest
    static void test(){
        
        Integer varFileNumber = 0;
        String paramRunId = 'someid';
        String paramStatus = '';
        String paramErrorMessage = 'Simple param error message';
        List<id> paramListIdContentVersion = new List<Id>();
        
        Set<String> paramSetEmailProcessed = new Set<String>();
        
        Test.startTest();
		HDT_BA_AttributesContact ac = new HDT_BA_AttributesContact(varFileNumber,paramRunId,paramStatus,paramErrorMessage,paramListIdContentVersion,paramSetEmailProcessed);
        ac.setEmailContactProcessed = new Set<String>();
        ac.setEmailContactProcessed.add('email@0.it');
        Database.executeBatch(ac,200);
        Test.stopTest();
        
        List <ContentVersion> lista = [Select id from ContentVersion where Title LIKE 'heradmp_firstpartydata_%'];
        System.assertEquals(false, lista.isEmpty(),'AttributesContact did not execute correctly');
    }
    
    
     @isTest
    static void testParam(){
        
        Integer varFileNumber = 0;
        String paramRunId = 'someid';
        String paramStatus = '';
        String paramErrorMessage = 'Simple param error message';
        List<id> paramListIdContentVersion = new List<Id>();
        
        Set<String> paramSetEmailProcessed = new Set<String>();
        paramSetEmailProcessed.add('email@0.it');
        
        Test.startTest();
		HDT_BA_AttributesContact ac = new HDT_BA_AttributesContact(varFileNumber,paramRunId,paramStatus,paramErrorMessage,paramListIdContentVersion,paramSetEmailProcessed);
        Database.executeBatch(ac,200);
        Test.stopTest();
        
        List <ContentVersion> lista = [Select id from ContentVersion where Title LIKE 'heradmp_firstpartydata_%'];
        System.assertEquals(false, lista.isEmpty(),'AttributesContact did not execute correctly');
    }

}