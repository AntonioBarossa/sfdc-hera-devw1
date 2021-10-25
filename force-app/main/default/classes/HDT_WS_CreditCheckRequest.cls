/**
 * @author alessandro.picchiri@eng.it
 * @date 28/05/2021 
*/
public class HDT_WS_CreditCheckRequest extends HDT_WS_Request {

    @AuraEnabled public String sistema;
    @AuraEnabled public String caso;
    @AuraEnabled public String crmEntity;
    @AuraEnabled public String crmId;    
    @AuraEnabled public String userId;
    @AuraEnabled public String activationUser;
    @AuraEnabled public String account;
    @AuraEnabled public String jobTitle;
    @AuraEnabled public String internalCustomerId;
    @AuraEnabled public String companyName;
    @AuraEnabled public String externalCustomerId;
    @AuraEnabled public String secondaryCustomerId;
    @AuraEnabled public String bpClass;
    @AuraEnabled public String bpCategory;
    @AuraEnabled public String bpType;
    @AuraEnabled public String customerType;
    @AuraEnabled public String address;
    @AuraEnabled public String municipality;
    @AuraEnabled public String district;
    @AuraEnabled public String postCode;
    @AuraEnabled public String operation;
    @AuraEnabled public String companyGroup;
    @AuraEnabled public String market;
    @AuraEnabled public String offerType;    
    @AuraEnabled public String bpAlternative;  
    @AuraEnabled public String alternativeCustomerId; 
    @AuraEnabled public List<HDT_WRP_InputWrapperDetail> details;
    
    public class HDT_WRP_InputWrapperDetail {        
        @AuraEnabled public String annualConsumption;
        @AuraEnabled public String commodity;
        @AuraEnabled public String totalConsumption;
    }
}