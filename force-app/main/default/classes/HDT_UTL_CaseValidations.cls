public inherited sharing class HDT_UTL_CaseValidations implements HDT_UTL_CaseValidationInterface {

    public String validate(String fields, String recordId){

        String caseType = [SELECT Type FROM Case WHERE Id = :recordId].Type;

        String result;

        if(caseType == 'Reclamo Scritto/Rich. Info'){

            //result = validateReclamoScritto(fields, recordId);

        } else if(caseType == 'Doppi Pagamenti/Incassi' || caseType == 'Piano Rateizzazione' || caseType == 'Richiesta Domiciliazione'
        || caseType == 'Variazione Domiciliazione' || caseType == 'Rimborso' || caseType == 'Attivazione Click&Pay' || 
        caseType == 'Storno Rateizzazione'){

            result = validatePagamenti(fields, caseType);

        } else if (caseType == 'Inversione del Contatore') {
            result = validateInversioneContatore(recordId, fields, caseType);
        }

        return result;

    }

    public String validatePagamenti(String fields, string caseType){

        String result;

        System.debug(caseType);

        System.debug(getFieldValue(fields, 'Type'));

        if(caseType != getFieldValue(fields, 'Type')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile modificare tipo processo'));

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }

        return result;

    }

    public String validateInversioneContatore(String caseId, String fields, string caseType) {

        String result;

        String relatedCaseId = getFieldValue(fields, 'RelatedCase__c');

        Case currentCase = [SELECT Id, CommodityFormula__c, ServicePoint__r.ServicePointCode__c FROM Case WHERE Id = :caseId];
        Case relatedCase = [SELECT Id, CommodityFormula__c, ServicePoint__r.ServicePointCode__c FROM Case WHERE Id = :relatedCaseId];

        System.debug('Related case commodity:' + relatedCase.CommodityFormula__c);

        if (!relatedCase.CommodityFormula__c.equalsIgnoreCase(currentCase.CommodityFormula__c)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Servizio incompatibile. Case attuale: ' + currentCase.CommodityFormula__c + ', Case correlato: ' + relatedCase.CommodityFormula__c));
        } else if (relatedCase.ServicePoint__r.ServicePointCode__c.equalsIgnoreCase(currentCase.ServicePoint__r.ServicePointCode__c)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Non è possibile correlare due processi di Inversione Contatore sullo stesso impianto'));
        } else {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        }

        return result;
    }


    /*public String validateReclamoScritto(String fields, string recordId){

        String result;

        Case c = [SELECT evr_PrimoLivello__c, evr_TipologiaReclamo__c, evr_QuintoLivello__c FROM Case WHERE Id = :recordId];

        if(c.evr_PrimoLivello__c != getFieldValue(fields, 'evr_PrimoLivello__c') || c.evr_TipologiaReclamo__c != getFieldValue(fields, 'evr_TipologiaReclamo__c')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Tipologia Reclamo e/o Primo Livello non Modificabile'));

        } else if((c.evr_QuintoLivello__c == null || c.evr_QuintoLivello__c == '') && 
                    (getFieldValue(fields, 'evr_VendutoDa__c') == null || getFieldValue(fields, 'evr_VendutoDa__c') == '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Venduto da è valorizzabile solo se è valorizzato il 5° Livello'));

        } else {
        
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
            
        }

        return result;

    }*/


    public String getFieldValue(String fields, String fieldToGet){

        String gotField;

        gotField = fields.replace('\"','').replace('{','').replace('}','');

        //System.debug('Indice campo '+ fieldToGet + ': ' + fields.indexOf(fieldToGet));
        
        gotField = gotField.substring(fields.indexOf(fieldToGet));

        //System.debug('GotField String: ' +gotField);

        gotField = gotField.substringBefore(',').substringAfter(':');

        //System.debug('GotField final: '+ gotField);

        return gotField;

    }

}