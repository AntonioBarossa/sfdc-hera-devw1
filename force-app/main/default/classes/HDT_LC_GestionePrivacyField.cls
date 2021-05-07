public with sharing class HDT_LC_GestionePrivacyField {
   
    @AuraEnabled
    public static void updateIndividual(String recordId,String type,Map<String,String> indvData){

                                         


        String individualId ='';

        if (type =='Contact'){
            Contact cont  = HDT_QR_Contact.getRecordById(recordId);
            individualId = cont.IndividualId;
            System.debug(cont);
        } 
        else if (type =='Lead'){
            Lead l = HDT_QR_Lead.getRecordById(recordId);
            individualId = l.IndividualId;
            System.debug(l);
        }

      
        Individual indv = new Individual(Id = individualId, MarketingPrivacy__c =  indvData.get('MarketingPrivacy'),PrivacyMarketingChoiceSource__c = indvData.get('PrivacyMarketingChoiceSource'),MarketingCompanyConsent__c = indvData.get('MarketingCompanyConsent'),MarketingConsentInitiative__c = indvData.get('MarketingConsentInitiative'), 
        ProfilingPrivacy__c = indvData.get('ProfilingPrivacy'),PrivacyProfilingChoiceSource__c= indvData.get('PrivacyProfilingChoiceSource'),ProfilingCompanyConsent__c = indvData.get('ProfilingCompanyConsent'),ProfilingConsentInitiative__c = indvData.get('ProfilingConsentInitiative'),
        ThirdPartyPrivacy__c = indvData.get('ThirdPartyPrivacy'),DataThirdPartiesConsentSource__c= indvData.get('DataThirdPartiesConsentSource'),ThirdPartyCompanyConsent__c = indvData.get('ThirdPartyCompanyConsent'),PrivacyThirdPartyConsentInitiative__c =indvData.get('PrivacyThirdPartyConsentInitiative'));


        //HDT_SRV_Individual.checkCreateAccess(indv);
        HDT_SRV_Individual.updateRecord(indv);
            
            
                      
      
    }

}