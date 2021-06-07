/**
 * @author alessandro.picchiri@eng.it
 * @date 28/05/2021 
*/
public class HDT_WS_CreditCheckRequest  extends HDT_WS_Request {


    @AuraEnabled Public String sistema;
    @AuraEnabled Public String caso;
    @AuraEnabled Public String crmEntity;
    @AuraEnabled Public String crmId;    
    @AuraEnabled Public String userId;
    @AuraEnabled Public String activationUser;
    @AuraEnabled Public String account;
    @AuraEnabled Public String jobTitle;
    @AuraEnabled Public String internalCustomerId;
    @AuraEnabled Public String companyName;
    @AuraEnabled Public String externalCustomerId;
    @AuraEnabled Public String secondaryCustomerId;
    @AuraEnabled Public String bpClass;
    @AuraEnabled Public String bpCategory;
    @AuraEnabled Public String bpType;
    @AuraEnabled Public String customerType;
    @AuraEnabled Public String address;
    @AuraEnabled Public String municipality;
    @AuraEnabled Public String district;
    @AuraEnabled Public String postCode;
    @AuraEnabled Public String operation;
    @AuraEnabled Public String companyGroup;
    @AuraEnabled Public String market;
    @AuraEnabled Public String offerType;    
    @AuraEnabled Public List<HDT_WS_CreditCheck.inputWrapperDetail> details;
    
    
    public HDT_WS_CreditCheckRequest(HDT_WS_CreditCheck.inputWrapper wrpVals){

        system.debug('HDT_WS_CreditCheckRequest - HDT_WS_CreditCheckRequest: wrpVals ----> ' + JSON.serialize(wrpVals));   

        this.sistema = wrpVals.sistema;
        this.caso = wrpVals.caso;
        this.crmEntity = wrpVals.crmEntity;
        this.crmId = wrpVals.crmId;        
        this.userId = wrpVals.userId;
        this.activationUser = wrpVals.activationUser;
        this.account = wrpVals.account;
        this.jobTitle = wrpVals.jobTitle;
        this.internalCustomerId = wrpVals.internalCustomerId;
        this.companyName = wrpVals.companyName;
        this.externalCustomerId = wrpVals.externalCustomerId;        
        this.secondaryCustomerId = wrpVals.secondaryCustomerId;
        this.bpClass = wrpVals.bpClass;
        this.bpCategory = wrpVals.bpCategory;
        this.bpType = wrpVals.bpType;
        this.customerType = wrpVals.customerType;
        this.address = wrpVals.address;
        this.municipality = wrpVals.municipality;
        this.district = wrpVals.district;
        this.postCode = wrpVals.postCode;
        this.operation = wrpVals.operation;
        this.companyGroup = wrpVals.companyGroup;
        this.market = wrpVals.market;
        this.offerType = wrpVals.offerType;        
        this.details = wrpVals.details;        
    }

}