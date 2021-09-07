/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 02/09/2021
* @description HDT_UTL_Individual for Test Classes
* @history Elfrida Kora – 02/09/2021 – Created class
*/

@IsTest
public class HDT_UTL_IndividualTst {
    @TestSetup
    static void makeData() 
    {
        
        List<Individual> individualList = HDT_UTL_DataFactoryTst.createIndividual(1,true);
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
        List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1,true);

         
        }
    
     @isTest
    public static void testConsentIndividual(){
        
         Test.startTest();

          
          List<Contact> contactId =[SELECT Id FROM Contact];
          List<String> listString = new List<String>(); 
          listString.add(String.valueOf(contactId[0].Id));
        
        List<Lead> leadId =[SELECT Id FROM Lead];
        List<String> lstString = new List<String>();
        
        lstString.add(String.valueOf(leadId[0].Id));
        List<Individual> indv =[SELECT Id,PrivacyMarketingChoiceSource__c,PrivacyMarketingConsentInitiative__c,PrivacyThirdPartyChoiceSource__c, 
                                PrivacyMarketingChoiceDate__c,LastName,FirstName,ProfilingCompanyConsent__c,ThirdPartyPrivacyVersion__c,PrivacyThirdPartyConsentInitiative__c,
                                ProfilingPrivacyVersion__c,PrivacyProfilingChoiceSource__c,PrivacyProfilingConsentInitiative__c,PrivacyProfilingChoiceDate__c,
                                MarketingPrivacyVersion__c,MarketingCompanyConsent__c,ThirdPartyCompanyConsent__c,PrivacyThirdPartyChoiceDate__c FROM Individual];
        Individual ind = (Individual)indv[0];
        Date todayD = date.today(); 

        
        HDT_UTL_Individual.createIndividualContact(listString);
        List<Individual> indvl =[SELECT Id FROM Individual];
        System.debug('size:' +indvl.size());
        System.debug('listaInd:' +indvl);

        
        
        System.assertEquals(4,indvl.size(),'This is the right value');
        //System.assertNotEquals(2,indvl.size(),'Size is four');
        Test.stopTest();
        
            
        }
    @isTest
    public static void testCreateIndividualLead(){
        Test.startTest();
        List<Lead> leadId =[SELECT Id FROM Lead];
        List<String> lstString = new List<String>();
         lstString.add(String.valueOf(leadId[0].Id));
         HDT_UTL_Individual.createIndividualLead(lstString);
         List<Lead> l =[SELECT Id FROM Lead];
        List<Individual> indvl =[SELECT Id FROM Individual];
        
        System.assertEquals(4,indvl.size(),'This is the right value');
        //System.assertNotEquals(2,indvl.size(),'Size is two');
        Test.stopTest();
    }
    
     @isTest
    public static void updateConsensoMarketingPrivacy(){
                Test.startTest();
         List<Individual> indv =[SELECT Id,MarketingPrivacyVersion__c FROM Individual];
        Date todayD = date.today(); 
        
           HDT_UTL_Individual.updateConsensoMarketingPrivacy(indv[0],'test','Evento','chat',todayD,'HCM');
                 List<Individual> indvFour =[SELECT Id,MarketingPrivacyVersion__c FROM Individual];

        System.assertEquals(indv[0].Id,indvFour[0].Id,'This is the right value');
        //System.assertNotEquals(2,indv.size(),'Size is two');
        Test.stopTest();
    }
        
    @isTest
    public static void updateConsensoProfilazionePrivacy(){
        Test.startTest();
        List<Individual> indv =[SELECT Id,ProfilingPrivacyVersion__c FROM Individual];
        Date todayD = date.today();
          HDT_UTL_Individual.updateConsensoProfilazionePrivacy(indv[0],'Frida','SOL','plico contrattuale',todayD,'MMS');
         List<Individual> indvUpdates =[SELECT Id,ProfilingPrivacyVersion__c FROM Individual];
        System.assertEquals(indv[0].Id,indvUpdates[0].Id,'This is the right value');
        //System.assertNotEquals(2,indv.size(),'Size is two');
        Test.stopTest();
    }
    
     @isTest
    public static void modifyContentPrivacyMarketing(){
        Test.startTest();
        List<Individual> indv =[SELECT Id,MarketingPrivacyVersion__c FROM Individual];
        Date todayD = date.today();
         Individual indvReturn = HDT_UTL_Individual.modifyContentPrivacyMarketing(indv[0],'Elfrida','Agenzia','APP My Hera',todayD ,'AAA');
        System.debug('indvReturn' +indvReturn);
         List<Individual> indvUpdate =[SELECT Id,MarketingPrivacyVersion__c,PrivacyMarketingConsentInitiative__c FROM Individual];
        System.assertEquals(indv[0].Id,indvReturn.Id,'This is the right value');
        //System.assertNotEquals(2,indv.size(),'Size is two');
                Test.stopTest();
    }
        
     @isTest
    public static void modifyContentPrivacyProfiling(){
                Test.startTest();
        List<Individual> indv =[SELECT Id,ProfilingPrivacyVersion__c FROM Individual];
        Date todayD = date.today();
          Individual indvOne = HDT_UTL_Individual.modifyContentPrivacyProfiling(indv[0],'Kora','App','APP My Hera',todayD,'NEWCO');
        List<Individual> indvUp =[SELECT Id,ProfilingPrivacyVersion__c FROM Individual];
        System.assertEquals(indv[0].Id,indvOne.Id,'This is the right value');
        //System.assertNotEquals(2,indv.size(),'Size is two');
        Test.stopTest();
    }
        
     @isTest
    public static void modifyContentPrivacyThirdParty(){
        Test.startTest();
        List<Individual> indv =[SELECT Id,ThirdPartyPrivacyVersion__c FROM Individual];
        Date todayD = date.today();
          Individual indvTwo = HDT_UTL_Individual.modifyContentPrivacyThirdParty(indv[0],'Italy','Call Center','landing page standard',todayD,'EB');
        List<Individual> indvUps =[SELECT Id,ThirdPartyPrivacyVersion__c FROM Individual];
        System.assertEquals(indv[0].Id,indvTwo.Id,'This is the right value');
        //System.assertNotEquals(2,indv.size(),'Size is two');
        Test.stopTest();
    }
        
      @isTest
    public static void modifyFieldValue(){
                Test.startTest();
        List<Individual> indv =[SELECT Id,PrivacyMarketingChoiceSource__c,PrivacyMarketingConsentInitiative__c,PrivacyThirdPartyChoiceSource__c, 
                                PrivacyMarketingChoiceDate__c,LastName,FirstName,ProfilingCompanyConsent__c,ThirdPartyPrivacyVersion__c,PrivacyThirdPartyConsentInitiative__c,
                                ProfilingPrivacyVersion__c,PrivacyProfilingChoiceSource__c,PrivacyProfilingConsentInitiative__c,PrivacyProfilingChoiceDate__c,
                                MarketingPrivacyVersion__c,MarketingCompanyConsent__c,ThirdPartyCompanyConsent__c,PrivacyThirdPartyChoiceDate__c FROM Individual];
        Date todayD = date.today();
        Map<String,object> params= new Map<String, object>();
        params.put('LastName',indv[0].LastName);
        
                        HDT_UTL_Individual.modifyFieldValue(params, indv[0].Id);
        
        System.assertEquals(3,indv.size(),'This is the right value');
             Test.stopTest();
    }
    
    @isTest
    public static void convertLeadToContact(){
            Test.startTest();
        List<Individual> indv =[SELECT Id,PrivacyMarketingChoiceSource__c,PrivacyMarketingConsentInitiative__c,PrivacyThirdPartyChoiceSource__c, 
                                PrivacyMarketingChoiceDate__c,LastName,FirstName,ProfilingCompanyConsent__c,ThirdPartyPrivacyVersion__c,PrivacyThirdPartyConsentInitiative__c,
                                ProfilingPrivacyVersion__c,PrivacyProfilingChoiceSource__c,PrivacyProfilingConsentInitiative__c,PrivacyProfilingChoiceDate__c,
                                MarketingPrivacyVersion__c,MarketingCompanyConsent__c,ThirdPartyCompanyConsent__c,PrivacyThirdPartyChoiceDate__c FROM Individual];
       
		 List<Contact> contactList = [SELECT Id FROM Contact];
          HDT_UTL_Individual.convertLeadToContact(contactList[0].Id, indv[0].Id);
        
        System.assertEquals(3,indv.size(),'This is the right value');
        //System.assertNotEquals(2,indv.size(),'Size is two');
          Test.stopTest();
        
    }

}