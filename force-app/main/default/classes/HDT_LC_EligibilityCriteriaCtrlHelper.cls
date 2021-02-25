public inherited sharing class HDT_LC_EligibilityCriteriaCtrlHelper {

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveEligibilityCriteriaHelper(List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province> provinceList, String productId){
        
        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();

        Savepoint sp = Database.setSavepoint();

        EligibilityCriteria__c criteria = new EligibilityCriteria__c();
        criteria.Regions__c = 'EMR';
        criteria.Product__c = productId;

        try{
            insert criteria;
        } catch (Exception e){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
            saveResponse.dataError = false;
            return saveResponse;
        }

        List<EligibleMunicipality__c> muniList = new List<EligibleMunicipality__c>();
        EligibleMunicipality__c muni;
        for(HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv : provinceList){
            if(singleProv.isEnabled){
                muni = new EligibleMunicipality__c();
                muni.EligibilityCriteria__c = criteria.Id;
                muni.Name = singleProv.label;
                muni.AreaCode__c =  singleProv.value;
                //singleProv.cityRemoved = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_City>();
                muni.JSON_Code__c = JSON.serialize(singleProv);
                muniList.add(muni);
            }
        }

        saveResponse.errorData = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError>();
        saveResponse.errorData = databaseInsert(muniList, saveResponse.errorData);

        if(saveResponse.errorData.size() > 0){
            Database.rollback(sp);
            saveResponse.success = false;
            saveResponse.message = '# ERROR: insert failed';
        } else {
            saveResponse.success = true;
            saveResponse.criteriaId = criteria.Id;
        }

        return saveResponse;

    }

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse cloneEligibilityCriteriaHelper(String recIdToClone, String productId){

        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();

        EligibilityCriteria__c newCriteria = new EligibilityCriteria__c();
        Savepoint sp = Database.setSavepoint();

        EligibilityCriteria__c crtiteriaToClone = [
            SELECT Id, Name,
                   (SELECT Id, Name, AreaCode__c, JSON_Code__c FROM EligibilityCriteria__r)
            FROM EligibilityCriteria__c
            WHERE Id =: recIdToClone
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        newCriteria = crtiteriaToClone.clone(false, true, false, false);
        newCriteria.Product__c = productId;

        System.debug('# clone this -> ' + newCriteria);

        try{
            insert newCriteria;
        } catch (Exception e){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
            saveResponse.dataError = false;
            return saveResponse;
        }

        List<EligibleMunicipality__c> newItemsList = new List<EligibleMunicipality__c>();
        EligibleMunicipality__c newItem;
        for(EligibleMunicipality__c itemToClone : crtiteriaToClone.EligibilityCriteria__r){
            newItem = itemToClone.clone(false, true, false, false);
            newItem.EligibilityCriteria__c = newCriteria.Id;
            newItemsList.add(newItem);
        }

        saveResponse.errorData = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError>();
        saveResponse.errorData = databaseInsert(newItemsList, saveResponse.errorData);

        if(saveResponse.errorData.size() > 0){
            Database.rollback(sp);
            saveResponse.success = false;
            saveResponse.message = '# ERROR: insert failed';
        } else {
            saveResponse.success = true;
            saveResponse.criteriaId = newCriteria.Id;
        }

        return saveResponse;

    }

    public static List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError> databaseInsert(List<EligibleMunicipality__c> itemList, List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError> errorData){

        List<Database.SaveResult> insertResults = Database.insert(itemList, false);

        for(Integer n=0; n<insertResults.size(); n++){
            Database.SaveResult sr = insertResults[n];

            if (!sr.isSuccess()) {
                // Operation failed
                String errorString = '';
                HDT_WRP_EligibilityCriteria.HDT_WRP_LineError lineError = new HDT_WRP_EligibilityCriteria.HDT_WRP_LineError();
                for(Database.Error err : sr.getErrors()) {
                    lineError.rowId = itemList[n].Name;
                    lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                }
                errorData.add(lineError);
            }
        }
   
        return errorData;
    }

}    