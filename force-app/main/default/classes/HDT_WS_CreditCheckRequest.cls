/**
 * @author alessandro.picchiri@eng.it
 * @date 28/05/2021 
*/
public class HDT_WS_CreditCheckRequest extends HDT_WS_Request {

    @AuraEnabled public String sistema { get; set; }
    @AuraEnabled public String caso { get; set; }
    @AuraEnabled public String crmEntity { get; set; }
    @AuraEnabled public String crmId { get; set; }    
    @AuraEnabled public String userId { get; set; }
    @AuraEnabled public String activationUser { get; set; }
    @AuraEnabled public String account { get; set; }
    @AuraEnabled public String jobTitle { get; set; }
    @AuraEnabled public String internalCustomerId { get; set; }
    @AuraEnabled public String companyName { get; set; }
    @AuraEnabled public String externalCustomerId { get; set; }
    @AuraEnabled public String secondaryCustomerId { get; set; }
    @AuraEnabled public String bpClass { get; set; }
    @AuraEnabled public String bpCategory { get; set; }
    @AuraEnabled public String bpType { get; set; }
    @AuraEnabled public String customerType { get; set; }
    @AuraEnabled public String address { get; set; }
    @AuraEnabled public String municipality { get; set; }
    @AuraEnabled public String district { get; set; }
    @AuraEnabled public String postCode { get; set; }
    @AuraEnabled public String operation { get; set; }
    @AuraEnabled public String companyGroup { get; set; }
    @AuraEnabled public String market { get; set; }
    @AuraEnabled public String offerType { get; set; }    
    @AuraEnabled public String bpAlternative { get; set; }  
    @AuraEnabled public String alternativeCustomerId { get; set; } 
    @AuraEnabled public List<HDT_WRP_InputWrapperDetail> details { get; set; } 
    
    public class HDT_WRP_InputWrapperDetail {        
        @AuraEnabled public String annualConsumption { get; set; } 
        @AuraEnabled public String commodity { get; set; } 
        @AuraEnabled public String totalConsumption { get; set; } 
    }
}