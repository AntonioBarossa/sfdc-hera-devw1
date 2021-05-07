public with sharing class HDT_LC_GestionePrivacyField {
    HDT_QR_Contact contactQR = new HDT_QR_Contact();
    HDT_QR_Lead leadQR = new HDT_QR_Lead();
    @AuraEnabled
    public static void updateIndividual(String recordId,String type,Map<String,String> indvData){

                                         


        String individualId ='';

        if (type =='Contact'){
            Contact cont  = contactQR.getRecordById(recordId);
            individualId = cont.IndividualId;
            System.debug(cont);
        } 
        else if (type =='Lead'){
            Lead l = leadQR.getRecordById(recordId);
            individualId = l.IndividualId;
            System.debug(l);
        }

      
        Individual indv = new Individual(Id = individualId, MarketingPrivacy__c =  indvData.get('MarketingPrivacy'),PrivacyMarketingChoiceSource__c = indvData.get('PrivacyMarketingChoiceSource'),MarketingCompanyConsent__c = indvData.get('MarketingCompanyConsent'),PrivacyMarketingConsentInitiative__c = indvData.get('PrivacyMarketingConsentInitiative'), 
        ProfilingPrivacy__c = indvData.get('ProfilingPrivacy'),PrivacyProfilingChoiceSource__c= indvData.get('PrivacyProfilingChoiceSource'),ProfilingCompanyConsent__c = indvData.get('ProfilingCompanyConsent'),PrivacyProfilingConsentInitiative__c = indvData.get('PrivacyProfilingConsentInitiative'),
        ThirdPartyPrivacy__c = indvData.get('ThirdPartyPrivacy'),PrivacyThirdPartyChoiceSource__c= indvData.get('PrivacyThirdPartyChoiceSource'),ThirdPartyCompanyConsent__c = indvData.get('ThirdPartyCompanyConsent'),PrivacyThirdPartyConsentInitiative__c =indvData.get('PrivacyThirdPartyConsentInitiative'));


        //HDT_SRV_Individual.checkCreateAccess(indv);
        HDT_SRV_Individual.updateRecord(indv);
            
            
                      
      
    }

}