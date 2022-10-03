/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 06/09/2022
 * @description Utilizzata nei record del custom metadata userinputflow per validare
 *              se il comune e le date di processo rientrano nei periodi di gestione della Tari
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_UTL_CityDataTariValidation implements HDT_UTL_CaseValidationInterface{

    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();
    Map<String, Object> fieldsMap=null;

    public String validate(String fields, String recordId){
        Case currentCase = caseValidationQr.getCaseById(recordId);
        //System.debug(LoggingLevel.DEBUG,'HDT_UTL_CaseValidations: validating Case ' + currentCase + ' @@@ '+currentCase.SupplyCity__c);        
        List<CityTechnicalData__c> cityData = HDT_LC_ActiveRepentant.getCityTecData(currentCase.SupplyCity__c);

        this.fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        String result;

        if(!cityData.isEmpty()){
            result=checkDates(cityData[0]);
        }

        //system.debug(result);
        if(result == null)  {result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));}
        return result;
    }

    private String checkDates(CityTechnicalData__c cityData){
        Date effectiveDate = convertDdMmYyyy((String)this.fieldsMap.get('EffectiveDate__c'));
        Date declarationDate = convertDdMmYyyy((String)this.fieldsMap.get('DeclarationDate__c'));
        /*
        system.debug('@@@@'+effectiveDate);
        system.debug('@@@@'+declarationDate);
        system.debug('@@@@'+cityData.TARIManagingEndDate__c);
        system.debug('@@@@'+cityData.CutOverEndDate__c);
        system.debug('@@@@'+cityData.TARIManagingEndDate__c);
        */
        if(cityData.CutOverEndDate__c != null && declarationDate != null && cityData.CutOverEndDate__c < declarationDate ){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'La data di contatto è successiva a quella di fine cut-over!'));
        }
        if(cityData.TARIManagingStartDate__c != null && effectiveDate != null && cityData.TARIManagingEndDate__c!=null){
            Boolean condition = cityData.TARIManagingStartDate__c > effectiveDate;
            condition|=cityData.TARIManagingEndDate__c < effectiveDate;
            if(condition){
                return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'La Data di decorrenza è precedente alla data inizio o successiva alla data fine del servizio ambiente.'));
            }
        }
        if(effectiveDate == null && declarationDate == null && cityData.TARIManaged__c == 'N'){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error',cityData.CityNotManagedAlert__c));
        }

        return null;
    }

    private Date convertDdMmYyyy(String ddmmyyyy)
    {
        if(String.isNotBlank(ddmmyyyy)){
            List<String> listToConvert = ddmmyyyy.split('-');
            return Date.newInstance(Integer.valueOf(listToConvert[0]), Integer.valueOf(listToConvert[1]), Integer.valueOf(listToConvert[2]));
        }
        return null;
    }
}