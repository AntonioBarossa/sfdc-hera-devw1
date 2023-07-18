/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 13/07/2021
* @description Class HDT_QR_ComfortQualityCall
* @history Keltin Mesonjesi – 13/07/2021 – Created class
*/
public inherited sharing class HDT_QR_ComfortQualityCall {
    
    public static List<ComfortQualityCall__c> getRecordByOrderParams(Order order){
        return getRecordByOrderParamsMassive(new List<Order>{order},order.SignatureMethod__c);
    }

    //modifica query in modo da poterla da essere utilizzabile in HDT_LC_OrderDossierWizardSignature
    public static List<ComfortQualityCall__c> getRecordByOrderParamsMassive(List<Order> orders,String signatureMethod){
        
        /* @frpanico 27/10/2021
         * Usato metodo StripInaccessible per risolvere problemi di
         * Inaccessible Field
         * Su processi di attivazione
         * @frpanico 2022-12-07 Cambiato puntamento da MarketOrigin__c a Market__c
		*/
        Map<String,Set<String>> mapQuery = getMapForQuery(orders);
        SObjectAccessDecision securityDecision =
            Security.stripInaccessible(accessType.READABLE,
            [SELECT
            Id,
            ComfortEnabled__c,
            QualityEnabled__c,
            Process__c,
            Channel__c,
            MarketType__c,
            CustomerType__c,
            DaysComfort__c,
            UniqueQuality__c,
            ComfortDocSendingChannel__c,
            QualitySignatureMethod__c,
            ComfortSignatureMethod__c
            FROM ComfortQualityCall__c
            WHERE Process__c IN :mapQuery.get('recordType') //text
            AND Channel__c IN :mapQuery.get('channel') //text
            AND CustomerType__c IN :mapQuery.get('customerCategory') //text
            AND MarketType__c IN :mapQuery.get('market') //picklist
            AND (ComfortSignatureMethod__c = :signatureMethod 
                OR QualitySignatureMethod__c = :signatureMethod)]);
        
        return securityDecision.getRecords();
        
        /*return [
            SELECT
            Id,
            ComfortEnabled__c,
            QualityEnabled__c,
            Process__c,
            Channel__c,
            MarketType__c,
            CustomerType__c,
            DaysComfort__c,
            UniqueQuality__c,
            ComfortDocSendingChannel__c,
            QualitySignatureMethod__c,
            ComfortSignatureMethod__c
            FROM ComfortQualityCall__c
            WHERE Process__c = :order.RecordType.DeveloperName //text
            AND Channel__c = :order.Channel__c //text
            AND CustomerType__c = :order.CustomerCategory__c //text
            AND MarketType__c = :order.MarketOrigin__c //picklist
            AND (ComfortSignatureMethod__c = :order.SignatureMethod__c 
                OR QualitySignatureMethod__c = :order.SignatureMethod__c)
            WITH SECURITY_ENFORCED
        ];*/
    }

    public static List<ComfortQualityCall__c> getRecordByOrderParamsVas(Order order){
        return getRecordByOrderParamsVasMassive(new List<Order>{order},order.SignatureMethod__c,order.DocSendingMethod__c);
    }

    public static List<ComfortQualityCall__c> getRecordByOrderParamsVasMassive(List<Order> orders,String signatureMethod,String docSendingMethod){
        Map<String,Set<String>> mapQuery = getMapForQuery(orders);
        return [
            SELECT
            Id,
            ComfortEnabled__c,
            QualityEnabled__c,
            Process__c,
            Channel__c,
            MarketType__c,
            CustomerType__c,
            DaysComfort__c,
            UniqueQuality__c,
            ComfortDocSendingChannel__c,
            QualitySignatureMethod__c,
            ComfortSignatureMethod__c
            FROM ComfortQualityCall__c
            WHERE Process__c IN :mapQuery.get('recordType') //text
            AND Channel__c IN :mapQuery.get('channel') //text
            AND CustomerType__c IN :mapQuery.get('customerCategory') //text
            AND (QualitySignatureMethod__c = :signatureMethod
                OR ComfortSignatureMethod__c = :signatureMethod
                OR ComfortDocSendingChannel__c = :docSendingMethod)
            WITH SECURITY_ENFORCED
        ];
    }

    private static void populateSetString(Set<String> queryValue, String value){
        if (String.isNotBlank(value)){
            queryValue.add(value);
        }
    }

    private static Map<String,Set<String>> getMapForQuery(List<Order> orders){
        Set<String> channel = new Set<String>();
        Set<String> recordType = new Set<String>();
        Set<String> customerCategory = new Set<String>();
        Set<String> market = new Set<String>();
        for (Order ord : orders){
            populateSetString(channel, ord.Channel__c);
            populateSetString(customerCategory, ord.CustomerCategory__c);
            populateSetString(market, ord.Market__c);
            populateSetString(recordType, ord.RecordType.DeveloperName);            
        }
        return new Map<String,Set<String>>{
            'channel' => channel,
            'customerCategory' => customerCategory,
            'recordType' => recordType,
            'market' => market
        };
    }
 
    public static List<ComfortQualityCall__c> getRecordsWithDocumentValidation(String canaleInvio){
        return [
            SELECT
            Id,
            ComfortEnabled__c,
            QualityEnabled__c,
            Process__c,
            Channel__c,
            MarketType__c,
            CustomerType__c,
            DaysComfort__c,
            UniqueQuality__c,
            ComfortDocSendingChannel__c
            FROM ComfortQualityCall__c
            WHERE DocumentValidation__c = true
            AND ComfortEnabled__c = true
            AND ComfortDocSendingChannel__c = :canaleInvio
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<ComfortQualityCall__c> getRecordsWithDocumentValidationAndQualityEnabled(){
        return [
            SELECT
            Id,
            Process__c,
            Channel__c,
            MarketType__c,
            CustomerType__c,
            UniqueQuality__c,
            ComfortDocSendingChannel__c,
            QualitySignatureMethod__c
            FROM ComfortQualityCall__c
            WHERE DocumentValidation__c = true
            AND QualityEnabled__c = true
            WITH SECURITY_ENFORCED
        ];
    }

}