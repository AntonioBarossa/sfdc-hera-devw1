/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 23/06/2021
* @description HDT_QR_MatriceAgenti
* @history Lorenzo – 23/06 – created class
*/
public with sharing class HDT_QR_MatriceAgenti {
    public static List<HDT_MatriceSocietaVendita__mdt> getAgente(String fornitura,String comune,string marcatura,String offerta){
        return [SELECT Service__c, isActive__c, Marcatura__c, Comune__c, SellerCompany__c, SalesCompanyCode__c, Offerta__c, QualifiedApiName, Label, NamespacePrefix, DeveloperName, Id 
                FROM HDT_MatriceSocietaVendita__mdt
                where Marcatura__c = :marcatura 
                AND comune__c = :comune
                AND service__c = :fornitura
                AND offerta__c = :offerta
                AND distributor__c = 'ALTRO'
                WITH SECURITY_ENFORCED
                ];
    }
    public static List<HDT_MatriceSocietaVendita__mdt> getAgenteException(String fornitura,String comune,string marcatura,String offerta,String distributor){
        String likeCondiction = '%' + distributor + '%';
        return [SELECT Service__c, isActive__c, Marcatura__c, Comune__c, SellerCompany__c, SalesCompanyCode__c, Offerta__c, QualifiedApiName, Label, NamespacePrefix, DeveloperName, Id 
                FROM HDT_MatriceSocietaVendita__mdt
                where Marcatura__c = :marcatura 
                AND comune__c = :comune
                AND service__c = :fornitura
                AND offerta__c = :offerta
                AND distributor__c LIKE :likeCondiction
                WITH SECURITY_ENFORCED
                ];
    }
    public static List<HDT_MatriceSocietaVendita__mdt> getAgenteExceptionList(){
        //String likeCondiction = '%' + distributor + '%';
        return [SELECT Service__c,distributor__c, isActive__c, Marcatura__c, Comune__c, SellerCompany__c, SalesCompanyCode__c, Offerta__c, QualifiedApiName, Label, NamespacePrefix, DeveloperName, Id 
                FROM HDT_MatriceSocietaVendita__mdt
                where distributor__c != 'ALTRO'
                WITH SECURITY_ENFORCED
                ];
    }
    public static List<HDT_MatriceSocietaVendita__mdt> getAgenteList(){
        return [SELECT Service__c,distributor__c, isActive__c, Marcatura__c, Comune__c, SellerCompany__c, SalesCompanyCode__c, Offerta__c, QualifiedApiName, Label, NamespacePrefix, DeveloperName, Id 
                FROM HDT_MatriceSocietaVendita__mdt
                where distributor__c = 'ALTRO'
                WITH SECURITY_ENFORCED
                ];
    }
}
