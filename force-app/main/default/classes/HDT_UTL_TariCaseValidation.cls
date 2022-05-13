@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class HDT_UTL_TariCaseValidation implements HDT_UTL_CaseValidationInterface {

    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();

    private Boolean isAllowableValue(String field){
        if(field!= null && !String.isBlank(field)){
            return true;
        }else{
            return false;
        }
    }

    public String validate(String fields, String recordId){

        Case currentCase = caseValidationQr.getCaseById(recordId);

        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        if(currentCase.RequestSource__c != 'D’ufficio' && currentCase.RequestSource__c != 'Da contribuente'){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Provenienza richiesta presenta un valore non ammesso'));
        }
        if(currentCase.DeclarationDate__c == null ){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Data dichiarazione presenta un valore non ammesso'));
        }

        if(currentCase.SubscriberType__c == ''){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È stato inserito un valore non ammissibile per il campo Qualità del Sottoscrittore'));
        }
        if(!this.isAllowableValue(currentCase.SubscriptionPlace__c)){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Luogo di Sottoscrizione non valorizzato'));
        }
        if(currentCase.EffectiveDate__c > System.today() && System.today() > currentCase.DeclarationDate__c){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È stato inserito un valore non ammissibile per il campo Data decorrenza '));
        }
        if(!this.isAllowableValue(currentCase.AttachmentsStringTARI__c)){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Allegati Obbligatori non valorizzati'));
        }
        if(!this.isAllowableValue(currentCase.ShipmentAddressAssign__c)){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Indirizzo di fornitura non valorizzato'));
        }
        if(currentCase.ModuleFromContributor__c != true  && currentCase.ModuleFromContributor__c != false){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È stato inserito un valore non ammissibile per il campo Modulo da Contribuente'));
        }
        if(!this.isAllowableValue(currentCase.ReliefToApply__c)){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Agevolazione da applicare non valorizzata'));
        }

        return result;

    }
}
