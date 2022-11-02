public with sharing class HDT_UTL_ExpSieRavv {

    @AuraEnabled(cacheable=false)
    public static void createExportSobjects(HDT_WRP_SieExport wrapper){
        //cancellare gli esistenti record di ravvedimento operoso
        HDT_UTL_DatabaseService.deleteSObject([Select id From ExpRavv__c Where Case__c =:wrapper.record.Id OR Order__c =:wrapper.record.Id]);
        //creare e inserire i nuovi
        List<ExpRavv__c> exportObjectsToInsert = getExportRavv(wrapper);
        HDT_UTL_DatabaseService.insertSObject(exportObjectsToInsert);
        return;
    }


    private static List<ExpRavv__c>  getExportRavv(HDT_WRP_SieExport wrapper, Case caseRavv){
        HDT_UTL_SieSobjectCreation createSobjUtl = new HDT_UTL_SieSobjectCreation(wrapper);
        List<ExpRavv__c> listToInsert = new List<ExpRavv__c>();
        if('x'.equalsIgnoreCase(wrapper.period)){//SE Periodo != "X"
            if('order'.equalsIgnoreCase(createSobjUtl.getSobjectType())){//SE  SOTTOTIPO è  'Nuovo contratto' ,'Subentro' ,'Subentro Cambio Cat.Tariffa' ,'Cambio Cat.Tariffa Stesso Cli.'
                // listToInsert.add(createSobjUtl.createExpRavv());
            }
        }
    }

    public with sharing class HDT_WRP_SieExport{
        @AuraEnabled public String period {get;set;}
        @AuraEnabled public String subtype {get;set;}
        @AuraEnabled public String cityCode {get;set;}
        @AuraEnabled public Sobject record {get;set;}
    }

    private with sharing class HDT_UTL_SieSobjectCreation{
        HDT_WRP_SieExport wrapper {get;set;}
        String sobjectTypeName {get;set;}
        HDT_UTL_SieSobjectCreation(HDT_WRP_SieExport wrapper){
            this.wrapper=wrapper;
            this.sobjectTypeName = wrapper.record.Id.getSobjectType().getDescribe().getName().toLowerCase();
        }

        getSobjectType(){
            return this.sobjectTypeName;
        }

        @SuppressWarnings('PMD.ExcessiveParameterList')
        ExpRavv__c createExpRavv(String operandName, String operandValue, Date initSuspension, Date endSuspension){
            ExpRavv__c exportRecord = new ExpRavv__c();
            exportRecord.OperandName__c = operandName;
            exportRecord.OperandValue__c = operandValue;
            exportRecord.SuspensionStartDate__c = initSuspension;
            exportRecord.SuspensionEndDate__c = endSuspension;
            exportRecord.CityCode__c = this.wrapper.cityCode;
            exportRecord.Type__c='Contratti';
            if('Subentro'.equalsIgnoreCase(this.wrapper.subtype)){   exportRecord.Subtype__c = 'Subentro';}
            else if(this.wrapper.subtype?.containsIgnoreCase('Attivazione')==true){ exportRecord.Subtype__c = 'Attivazione';}
            else { exportRecord.Subtype__c = 'Variazione';}
            switch on this.sobjectTypeName {
                when 'case' {
                    exportRecord.Case__c=this.wrapper.record.Id;
                }
                when 'order' {
                    exportRecord.Order__c=this.wrapper.record.Id;
                }
            }
            return exportRecord;
        }
    }
}
