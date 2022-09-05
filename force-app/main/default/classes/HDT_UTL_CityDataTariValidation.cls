public inherited sharing class HDT_UTL_CityDataTariValidation implements HDT_UTL_CaseValidationInterface{

    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();
    Map<String, Object> fieldsMap=null;

    public String validate(String fields, String recordId){
        Case currentCase = caseValidationQr.getCaseById(recordId);
        System.debug(LoggingLevel.DEBUG,'HDT_UTL_CaseValidations: validating Case ' + currentCase);        
        List<CityTechnicalData__c> cityData = HDT_LC_ActiveRepentant.getCityTecData(currentCase.SupplyCity__c);

        this.fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        String result;

        if(!cityData.isEmpty()){
            result=checkDates(cityData[0]);
        }


        if(STRING.isBlank(result))  {result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));}
        return result;
    }

    private String checkDates(CityTechnicalData__c cityData){
        if(cityData.CutOverEndDate__c != null && cityData.CutOverEndDate__c > (Date) this.fieldsMap.get('DeclarationDate__c') ){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'La data di contatto è successiva a quella di fine cut-over!'));
        }
        if(cityData.TARIManagingStartDate__c != null && cityData.TARIManagingEndDate__c!=null){
            Boolean condition = cityData.TARIManagingStartDate__c > (Date) this.fieldsMap.get('EffectiveDate__c');
            condition|=cityData.TARIManagingEndDate__c < (Date) this.fieldsMap.get('EffectiveDate__c');
            if(condition){
                return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', cityData.CityNotManagedAlert__c));
            }
        }
        return null;
    }
}
