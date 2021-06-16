/**
 * @author alessandro.picchiri@eng.it
 * @date 28/05/2021
 * @description  Classe che si occuperà di effettuare le chiamate al servizio esposto da mulesoft per la chiamata di EVALUATION CRM 
                 La classe popolerà l’input con i parametri del servizio di riferimento, recupererà l’endpoint specifico ed effettuerà la 
                 chiamata al servizio attraverso la classe “HDT_WS_HTTPServiceCall”. 
*/
public class HDT_WS_CreditCheck {

    @AuraEnabled
    public static HDT_WS_CreditCheckResponse callService(String wrpVals){
        
            system.debug('HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: wrpVals ----> ' + json.deserialize(wrpVals, HDT_VFC_InputWrapper.class));
            
            HDT_WS_CreditCheckRequest req = new HDT_WS_CreditCheckRequest((HDT_VFC_InputWrapper)json.deserialize(wrpVals, HDT_VFC_InputWrapper.class));
            
            system.debug('HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: req ----> ');
            system.debug(JSON.serializepretty(req));
            
            HDT_WS_CreditCheckResponse res = (HDT_WS_CreditCheckResponse)HDT_WS_HTTPServiceCall.sendRequest('CreditCheck', req,HDT_WS_CreditCheckResponse.class);
            
            system.debug('HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: res ----> ' + JSON.serialize(res));
            
            return res;                    
            
    }

    public class HDT_VFC_InputWrapper {

        Public String sistema;             
        Public String caso;                
        Public String crmEntity;           
        Public String crmId;               
        Public String userId;              
        Public String activationUser;      
        Public String account;             
        Public String jobTitle;            
        Public String internalCustomerId;  
        Public String companyName;         
        Public String externalCustomerId;  
        Public String secondaryCustomerId; 
        Public String bpClass;             
        Public String bpCategory;          
        Public String bpType;              
        Public String customerType;        
        Public String address;             
        Public String municipality;        
        Public String district;            
        Public String postCode;            
        Public String operation;           
        Public String companyGroup;        
        Public String market;              
        Public String offerType;  
        Public String bpAlternative;  
        Public String alternativeCustomerId;              
        Public List<HDT_VFC_InputWrapperDetail> details;    
    }

    public class HDT_VFC_InputWrapperDetail {        
        Public String annualConsumption;
        Public String commodity;
        Public String totalConsumption;
    }

   
}