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
        
            system.debug('HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: wrpVals ----> ' + json.deserialize(wrpVals, inputWrapper.class));
            
            HDT_WS_CreditCheckRequest req = new HDT_WS_CreditCheckRequest((inputWrapper)json.deserialize(wrpVals, inputWrapper.class));
            
            system.debug('HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: req ----> ');
            system.debug(JSON.serializepretty(req));
            
            HDT_WS_CreditCheckResponse res = (HDT_WS_CreditCheckResponse)HDT_WS_HTTPServiceCall.sendRequest('CreditCheck', req,HDT_WS_CreditCheckResponse.class);
            
            system.debug('HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: res ----> ' + JSON.serialize(res));
            
            return res;           
            
    }

    public class inputWrapper {

        Public String sistema;             // per ora inserire i valodi di default eEnergy  - DA DEFINIRE
        Public String caso;                //                                               - DA DEFINIRE  / NON OBBLIGATORI
        Public String crmEntity;           // Order.Name ??                                 - DA DEFINIRE
        Public String crmId;               // Id dell'ordine        
        Public String userId;              // CreateById dell'Ordine                        - DA DEFINIRE
        Public String activationUser;      // CreateById dell'Ordine                        - DA DEFINIRE
        Public String account;             // Account__c presente nell'order
        Public String jobTitle;            // Channel
        Public String internalCustomerId;  // Account__r.CustomerCode__c
        Public String companyName;         // SalesCompany__c
        Public String externalCustomerId;  // Account__r.FiscalCode__c      
        Public String secondaryCustomerId; // Account__r.VATNumber__c       
        Public String bpClass;             // Account__r.CustomerMarking__c
        Public String bpCategory;          // Account__r.Category__c
        Public String bpType;              // Account__r.Type__c                            - DA DEFINIRE
        Public String customerType;        //                                               - DA DEFINIRE 
        Public String address;             // ServicePoint__r.SupplyStreetName__c
        Public String municipality;        // ServicePoint__r.SupplyCity__c
        Public String district;            // ServicePoint__r.SupplyProvince__c
        Public String postCode;            // ServicePoint__r.SupplyPostalCode__c 
        Public String operation;           // ProcessType__c
        Public String companyGroup;        // Inserire il default Hera S.p.A.               - DA DEFINIRE  
        Public String market;              // Market__c
        Public String offerType;           // CommercialProduct__c o Catalog__c
        Public List<inputWrapperDetail> details;    
    }

    public class inputWrapperDetail {        
        Public String annualConsumption;
        Public String commodity;
        Public String totalConsumption;
    }

   
}