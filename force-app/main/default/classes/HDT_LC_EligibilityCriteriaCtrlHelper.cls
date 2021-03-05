public inherited sharing class HDT_LC_EligibilityCriteriaCtrlHelper {

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveEligibilityCriteriaHelper(String productId, String record, List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province> provinceList){
        
        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();

        Savepoint sp = Database.setSavepoint();

        EligibilityCriteria__c criteria = new EligibilityCriteria__c();
        criteria = (EligibilityCriteria__c)JSON.deserialize(record, EligibilityCriteria__c.class);
        //criteria.Regions__c = 'EMR';
        //criteria.Product__c = productId;

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

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode getExistingEligibleMunicipalities(String eligibilityId, HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode CityZipCodeObj){

        System.debug('# getExistingEligibleMunicipalities > ' + eligibilityId);
        CityZipCodeObj = new HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode();
        try{
            List<EligibleMunicipality__c> muniList = new List<EligibleMunicipality__c>();
            muniList = [
                SELECT Id, Name, AreaCode__c, JSON_Code__c
                FROM EligibleMunicipality__c
                WHERE EligibilityCriteria__c =: eligibilityId
                WITH SECURITY_ENFORCED
            ];
            
            
            CityZipCodeObj.regionList = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_Region>();
            HDT_WRP_EligibilityCriteria.HDT_WRP_Region singleRegion = new HDT_WRP_EligibilityCriteria.HDT_WRP_Region();
            singleRegion.regionName = 'EmiliaRomagna';
            singleRegion.regionCode = 'EMR';
            singleRegion.provinceList = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province>();

            HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv;
            for(EligibleMunicipality__c muni : muniList){
                singleProv = new HDT_WRP_EligibilityCriteria.HDT_WRP_Province();
                singleProv = (HDT_WRP_EligibilityCriteria.HDT_WRP_Province)JSON.deserialize(muni.JSON_Code__c, HDT_WRP_EligibilityCriteria.HDT_WRP_Province.class);
                singleRegion.provinceList.add(singleProv);
            }
            CityZipCodeObj.regionList.add(singleRegion);
            CityZipCodeObj.success = true;
            CityZipCodeObj.message = '';
        } catch (Exception e){
            CityZipCodeObj.success = false;
            CityZipCodeObj.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        system.debug(JSON.serialize(CityZipCodeObj));

        return CityZipCodeObj;

    }

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse deleteEligibilityCriteriaHelper(List<EligibilityCriteria__c> criteriaListToDelete, HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse){

        saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();
        saveResponse.errorData = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError>();
        Savepoint sp = Database.setSavepoint();

        List<Database.DeleteResult> deleteResults = Database.delete(criteriaListToDelete, false);

        for(Integer n=0; n<deleteResults.size(); n++){
            Database.DeleteResult dr = deleteResults[n];

            if (!dr.isSuccess()) {
                // Operation failed
                String errorString = '';
                HDT_WRP_EligibilityCriteria.HDT_WRP_LineError lineError = new HDT_WRP_EligibilityCriteria.HDT_WRP_LineError();
                for(Database.Error err : dr.getErrors()) {
                    lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                }
                saveResponse.errorData.add(lineError);
            }
        }

        if(saveResponse.errorData.size() > 0){
            Database.rollback(sp);
            saveResponse.success = false;
            saveResponse.message = '# ERROR: delete failed';
        } else {
            saveResponse.success = true;
            saveResponse.message = 'Criterio eliminato correttamente';
        }

        return saveResponse;

    }

    /*public static void updateEligibilityCriteria(Id product2Id, Boolean asChild){

        try{
            Product2 prod = new Product2();
            prod.Id = product2Id;
            prod.EligibilityCriteria__c = asChild;
            update prod;
        } catch (Exception e){
            System.debug('# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
        }

    }*/

}