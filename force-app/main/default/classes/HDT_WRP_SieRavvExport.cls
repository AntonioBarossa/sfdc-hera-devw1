public with sharing class HDT_WRP_SieRavvExport {
    @AuraEnabled public String period {get;set;}
    @AuraEnabled public String subtype {get;set;}
    @AuraEnabled public String cityCode {get;set;}
    @AuraEnabled public Date declarationDate {get;set;}
    @AuraEnabled public Date effectiveDate {get;set;}
    @AuraEnabled public Date limitDateX {get;set;}
    @AuraEnabled public Sobject record {get;set;}
    @AuraEnabled public String missingDue {get;set;}
}
