/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/2021
* @description HDT_TRH_BillingProfile 
* @history Sabina Levonja – 04/06/2021 – created class 
*/
public inherited sharing class HDT_TRH_BillingProfile extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        for(SObject obj : trigger.new){
            BillingProfile__c bp = (BillingProfile__c)obj;
            if(String.isNotBlank(bp.BankAccountSignatoryFiscalCode__c) && bp.BankAccountSignatoryFiscalCode__c.length() == 16){
                String fiscalCode = bp.BankAccountSignatoryFiscalCode__c;
                String lastLetter = fiscalCode.right(1);
                String fiscalCodeToCheck = fiscalCode.left(15);
                String letterControled = HDT_UTL_CalculateFiscalCode.getControlLetter(fiscalCodeToCheck);

                if(lastLetter != letterControled ){
                    bp.addError('Codice fiscale non valido');
                }
            }
            else{
                if(String.isNotBlank(bp.BankAccountSignatoryFiscalCode__c) && bp.BankAccountSignatoryFiscalCode__c.length() != 16){
                    bp.addError('Codice fiscale non valido');
                }
            }
        }
    }

    public override void beforeUpdate(){
        HDT_UTL_GlobaMigrationKey.setGlobalMigrationKey(Trigger.new, Trigger.oldMap);
        for(Id bpId : trigger.newMap.keySet()){
            BillingProfile__c bpNew = (BillingProfile__c)Trigger.newMap.get(bpId);
            BillingProfile__c bpOld = (BillingProfile__c)Trigger.oldMap.get(bpId);
            if(Trigger.oldMap.containsKey(bpId) && bpOld.BankAccountSignatoryFiscalCode__c != bpNew.BankAccountSignatoryFiscalCode__c && bpNew.BankAccountSignatoryFiscalCode__c.length() == 16){
                String fiscalCode = bpNew.BankAccountSignatoryFiscalCode__c;
                String lastLetter = fiscalCode.right(1);
                String fiscalCodeToCheck = fiscalCode.left(15);
                String letterControled = HDT_UTL_CalculateFiscalCode.getControlLetter(fiscalCodeToCheck);

                if(lastLetter != letterControled ){
                    bpNew.addError('Codice fiscale non valido');
                }
            }
            else{
                if(bpOld.BankAccountSignatoryFiscalCode__c != bpNew.BankAccountSignatoryFiscalCode__c && bpNew.BankAccountSignatoryFiscalCode__c.length() != 16){
                    bpNew.addError('Codice fiscale non valido');
                }
            }
        }
    }
}