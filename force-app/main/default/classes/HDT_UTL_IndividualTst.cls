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
        System.assertNotEquals(2,indvl.size(),'Size is four');
        
           HDT_UTL_Individual.createIndividualLead(lstString);
         List<Lead> l =[SELECT Id FROM Lead];
        
        System.assertEquals(4,indvl.size(),'This is the right value');
        System.assertNotEquals(2,indvl.size(),'Size is two');
        
           HDT_UTL_Individual.updateConsensoMarketingPrivacy(ind,'test','Evento','chat',todayD,'HCM');
        
        System.assertEquals(4,indvl.size(),'This is the right value');
        System.assertNotEquals(2,indvl.size(),'Size is two');
        
           HDT_UTL_Individual.updateConsensoProfilazionePrivacy(ind,'Frida','SOL','plico contrattuale',todayD,'MMS');
        
        System.assertEquals(4,indvl.size(),'This is the right value');
        System.assertNotEquals(2,indvl.size(),'Size is two');
        
           HDT_UTL_Individual.modifyContentPrivacyMarketing(ind,'Elfrida','Agenzia','APP My Hera',todayD ,'AAA');
        
        System.assertEquals(4,indvl.size(),'This is the right value');
        System.assertNotEquals(2,indvl.size(),'Size is two');
        
           HDT_UTL_Individual.modifyContentPrivacyProfiling(ind,'Kora','App','APP My Hera',todayD,'NEWCO');
        
        System.assertEquals(4,indvl.size(),'This is the right value');
        System.assertNotEquals(2,indvl.size(),'Size is two');
        
           HDT_UTL_Individual.modifyContentPrivacyThirdParty(ind,'Italy','Call Center','landing page standard',todayD,'EB');
        
        System.assertEquals(4,indvl.size(),'This is the right value');
        System.assertNotEquals(2,indvl.size(),'Size is two');
        
        
        
        Map<String,object> params= new Map<String, object>();
        params.put('LastName',ind.LastName);
        
                        HDT_UTL_Individual.modifyFieldValue(params, ind.Id);
        
        System.assertEquals(4,indvl.size(),'This is the right value');
        System.assertNotEquals(2,indvl.size(),'Size is two');
                       
         Contact cont = new Contact();
		cont.FirstName='Test';
            HDT_UTL_Individual.convertLeadToContact(cont.Id, ind.Id);
        
        
                Test.stopTest();
        
    }

}