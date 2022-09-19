/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 13/07/2021
* @description Class HDT_QR_ComfortQualityCall
* @history Keltin Mesonjesi – 13/07/2021 – Created class
*/
public inherited sharing class HDT_QR_ComfortQualityCall {
    
    public static List<ComfortQualityCall__c> getRecordByOrderParams(Order order){
        
        /* @frpanico 27/10/2021
         * Usato metodo StripInaccessible per risolvere problemi di
         * Inaccessible Field
         * Su processi di attivazione
		*/
        
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
            WHERE Process__c = :order.RecordType.DeveloperName //text
            AND Channel__c = :order.Channel__c //text
            AND CustomerType__c = :order.CustomerCategory__c //text
            AND MarketType__c = :order.MarketOrigin__c //picklist
            AND (ComfortSignatureMethod__c = :order.SignatureMethod__c 
                OR QualitySignatureMethod__c = :order.SignatureMethod__c)]);
        
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
            WHERE Process__c = :order.RecordType.DeveloperName //text
            AND Channel__c = :order.Channel__c //text
            AND CustomerType__c = :order.CustomerCategory__c //text
            AND (QualitySignatureMethod__c = :order.SignatureMethod__c
                OR ComfortSignatureMethod__c = :order.SignatureMethod__c
                OR ComfortDocSendingChannel__c = :order.DocSendingMethod__c)
            WITH SECURITY_ENFORCED
        ];
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