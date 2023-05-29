@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_LC_EligibilityCriteriaCtrlHelper {

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse setSaveResponse(HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse, String message, Boolean dataError){
        saveResponse.success = false;
        saveResponse.message = message;
        
        if(!dataError){
            saveResponse.dataError = false;
        }
        return saveResponse;
    }

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveEligibilityCriteriaHelper(String productId, String record, HDT_WRP_EligibilityCriteria.HDT_WRP_Region obj){

        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();

        Savepoint sp = Database.setSavepoint();

        Boolean isUpsert = false;
        EligibilityCriteria__c criteria = new EligibilityCriteria__c();
        criteria = (EligibilityCriteria__c)JSON.deserialize(record, EligibilityCriteria__c.class);
        criteria.EligibleForAllCities__c = obj.eligibleForAllCities;

        isUpsert = !String.isEmpty(criteria.Id);

        try{

           SObjectType objtype = Schema.getGlobalDescribe().get('EligibilityCriteria__c');
           Schema.DescribeSObjectResult objRes = objtype.getDescribe();

            if(objRes.isCreateable() && objRes.isUpdateable()){
                HDT_UTL_DatabaseService.upsertSObject(criteria);
            } else {
                return setSaveResponse(saveResponse, Label.HDT_EligCriteria_ErrorObj, false); 
            }

        } catch (Exception e){
            return setSaveResponse(saveResponse, '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']', false);
        }

        if(!criteria.EligibleForAllCities__c){

            Boolean deleteResponse = handleRecordDelete(isUpsert, criteria.Id);

            if(!deleteResponse){
                return setSaveResponse(saveResponse, Label.HDT_EligCriteria_DeleteError, true);  
            }

            List<EligibleMunicipality__c> muniList = new List<EligibleMunicipality__c>();
            EligibleMunicipality__c muni;
            for(HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv : obj.provinceList){
                if(singleProv.isEnabled){
                    muni = new EligibleMunicipality__c();
                    muni.EligibilityCriteria__c = criteria.Id;
                    muni.Name = singleProv.label;
                    muni.AreaCode__c =  singleProv.value;
                    //singleProv.cityRemoved = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_City>();
                    muni.JSONCode__c = JSON.serialize(singleProv);
                    //#### 24-02-2023 enhanced eligibleForAllCities
                    //if(!singleProv.eligibleForAllCities){
                    //    muni.JSONCode__c = JSON.serialize(singleProv);   
                    //}
                    //muni.EligibleForAllCities__c = singleProv.eligibleForAllCities;
                    //#### 24-02-2023 enhanced eligibleForAllCities

                    muniList.add(muni);
                }
            }

            saveResponse.errorData = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError>();
            saveResponse.errorData = databaseInsert(muniList, saveResponse.errorData);

            if(saveResponse.errorData.size() > 0){
                Database.rollback(sp);
                saveResponse.success = false;
                saveResponse.message = Label.HDT_EligCriteria_SaveError;
            } else {
                saveResponse.success = true;
                saveResponse.criteriaId = criteria.Id;
            }
        } else {

            Boolean deleteResponse = handleRecordDelete(isUpsert, criteria.Id);

            if(!deleteResponse){
                return setSaveResponse(saveResponse, Label.HDT_EligCriteria_DeleteError, true); 
            }

            saveResponse.success = true;
            saveResponse.criteriaId = criteria.Id; 
        }

        return saveResponse;

    }

    public static Boolean handleRecordDelete(Boolean isUpsert, String criteriaId){
        if(isUpsert){
            List<EligibleMunicipality__c> muniList;    
            muniList = HDT_QR_EligibilityCriteria.getEligibleMunicipalityByCriteriaId(muniList, criteriaId);
            if(muniList.size()>0){
                return HDT_UTL_DatabaseService.deleteSObject(muniList);
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse cloneEligibilityCriteriaHelper(String recIdToClone, String productId){

        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();

        EligibilityCriteria__c newCriteria = new EligibilityCriteria__c();
        Savepoint sp = Database.setSavepoint();

        EligibilityCriteria__c crtiteriaToClone;
        crtiteriaToClone = HDT_QR_EligibilityCriteria.getEligibilityCriteriaWithChild(crtiteriaToClone, recIdToClone);

        newCriteria = crtiteriaToClone.clone(false, true, false, false);
        newCriteria.Product__c = productId;

        System.debug(LoggingLevel.DEBUG, '# clone this -> ' + newCriteria);

        try{
            SObjectType objtype = Schema.getGlobalDescribe().get('EligibilityCriteria__c');
            Schema.DescribeSObjectResult objRes = objtype.getDescribe();
     
            if(objRes.isCreateable()){
                HDT_UTL_DatabaseService.insertSObject(newCriteria);
            } else {
                return setSaveResponse(saveResponse, Label.HDT_EligCriteria_ErrorObj, false);               
            }

        } catch (Exception e){
            return setSaveResponse(saveResponse, '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']', false); 
        }

        if(!crtiteriaToClone.EligibleForAllCities__c){
            List<EligibleMunicipality__c> newItemsList = new List<EligibleMunicipality__c>();
            EligibleMunicipality__c newItem;
            for(EligibleMunicipality__c itemToClone : crtiteriaToClone.Comuni_Eleggibili__r){
                //newItem = itemToClone.clone(false, true, false, false);
                newItem = new EligibleMunicipality__c();
                newItem.Name = itemToClone.Name;
                newItem.AreaCode__c = itemToClone.AreaCode__c;
                newItem.JSONCode__c = itemToClone.JSONCode__c;
                newItem.EligibilityCriteria__c = newCriteria.Id;
                newItemsList.add(newItem);
            }

            saveResponse.errorData = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError>();
            saveResponse.errorData = databaseInsert(newItemsList, saveResponse.errorData);

            if(saveResponse.errorData.size() > 0){
                Database.rollback(sp);
                saveResponse.success = false;
                saveResponse.message = Label.HDT_EligCriteria_SaveError;
            } else {
                saveResponse.success = true;
                saveResponse.criteriaId = newCriteria.Id;
            }
        } else {
            saveResponse.success = true;
            saveResponse.criteriaId = newCriteria.Id;          
        }

        return saveResponse;

    }

    public static List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError> databaseInsert(List<EligibleMunicipality__c> itemList, List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError> errorData){

        SObjectType objtype = Schema.getGlobalDescribe().get('EligibleMunicipality__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isCreateable()){

            List<Database.SaveResult> insertResults = Database.insert(itemList, false);

            for(Integer n=0; n<insertResults.size(); n++){
                Database.SaveResult sr = insertResults[n];

                if (!sr.isSuccess()) {
                    // Operation failed
                    /*
                        @Author: Davide Viola - 19/10/2021
                        Description: PMD -> Commentata variabile non utilizzata.
                    */
                    //String errorString = '';
                    HDT_WRP_EligibilityCriteria.HDT_WRP_LineError lineError = new HDT_WRP_EligibilityCriteria.HDT_WRP_LineError();
                    for(Database.Error err : sr.getErrors()) {
                        lineError.rowId = itemList[n].Name;
                        lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                    }
                    errorData.add(lineError);
                }
            }
        }

        return errorData;
    }

    public static Map<String, Set<String>> deserializeMethod(Map<String, Set<String>> existingMuniMap, List<EligibleMunicipality__c> muniList){
            HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv;
            for(EligibleMunicipality__c muni : muniList){
                
                //#### 24-02-2023 enhanced eligibleForAllCities
                //if(muni.EligibleForAllCities__c){
                //    existingMuniMap.put(muni.AreaCode__c, null);
                //    continue;
                //}
                //#### 24-02-2023 enhanced eligibleForAllCities

                singleProv = new HDT_WRP_EligibilityCriteria.HDT_WRP_Province();
                singleProv = (HDT_WRP_EligibilityCriteria.HDT_WRP_Province)JSON.deserialize(muni.JSONCode__c, HDT_WRP_EligibilityCriteria.HDT_WRP_Province.class);

                Set<String> tempSet = new Set<String>();
                for(HDT_WRP_EligibilityCriteria.HDT_WRP_City city : singleProv.cityAvailable){
                    tempSet.add(city.value);
                }
                existingMuniMap.put(muni.AreaCode__c, tempSet);
            }
            return existingMuniMap;
    }

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode getExistingEligibleMunicipalities(String eligibilityId, HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode cityZipCodeObj){

        System.debug(LoggingLevel.DEBUG, '# getExistingEligibleMunicipalities > ' + eligibilityId);

        Map<String, Set<String>> existingMuniMap = new Map<String, Set<String>>();

        cityZipCodeObj = new HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode();
        List<EligibleMunicipality__c> muniList;
        List<EligibilityCriteria__c> criteria;

        muniList = HDT_QR_EligibilityCriteria.getEligibleMunicipalityByCriteriaId(muniList, eligibilityId);
        criteria = HDT_QR_EligibilityCriteria.getEligibilityCriteriaSingleRecord(criteria, eligibilityId);

        try{            
            //+++++++++++++++++++++++++++++
            //existingMuniMap = deserializeUntypedMethod(existingMuniMap, muniList);
            //+++++++++++++++++++++++++++++
            existingMuniMap = deserializeMethod(existingMuniMap, muniList);

            cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.createDefaultCityZipCodeObj(cityZipCodeObj);
            cityZipCodeObj.regionList[0].eligibleForAllCities = criteria[0].EligibleForAllCities__c;

            for(HDT_WRP_EligibilityCriteria.HDT_WRP_Province prov : cityZipCodeObj.regionList[0].provinceList){

                if(existingMuniMap.containsKey(prov.value)){

                    //#### 24-02-2023 enhanced eligibleForAllCities
                    //if(existingMuniMap.get(prov.value) == null){
                    //    continue;
                    //}
                    //#### 24-02-2023 enhanced eligibleForAllCities

                    Set<String> avalilableCityCode = existingMuniMap.get(prov.value);
                    Set<Integer> itemsToRemove = new Set<Integer>();

                    for(HDT_WRP_EligibilityCriteria.HDT_WRP_City c : prov.cityAvailable){

                        if(!avalilableCityCode.contains(c.value)){
                            itemsToRemove.add(prov.cityAvailable.indexOf(c));
                            prov.cityRemoved.add(c);
                        }
                    }

                    for(Integer i = prov.cityAvailable.size() - 1; i >= 0; i--) {
                        if(itemsToRemove.contains(i)){
                            prov.cityAvailable.remove(i);
                        }
                    }

                    //System.debug(LoggingLevel.DEBUG, '>>> cityAvailable: ' + prov.cityAvailable.size());
                    //System.debug(LoggingLevel.DEBUG, '>>> cityRemoved: ' + prov.cityRemoved.size());

                } else {
                    prov.isEnabled = false;
                }
            }


            cityZipCodeObj.success = true;
            cityZipCodeObj.message = '';

        } catch (Exception e){
            cityZipCodeObj.success = false;
            cityZipCodeObj.message = '> ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return cityZipCodeObj;

    }

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse deleteEligibilityCriteriaHelper(List<EligibilityCriteria__c> criteriaListToDelete, HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse){

        saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();
        saveResponse.errorData = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_LineError>();
        Savepoint sp = Database.setSavepoint();

        SObjectType objtype = Schema.getGlobalDescribe().get('EligibilityCriteria__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isDeletable()){

            List<Database.DeleteResult> deleteResults = Database.delete(criteriaListToDelete, false);

            for(Integer n=0; n<deleteResults.size(); n++){
                Database.DeleteResult dr = deleteResults[n];

                if (!dr.isSuccess()) {
                    // Operation failed
                    /*
                        @Author: Davide Viola - 19/10/2021
                        Description: PMD -> Commentata variabile non utilizzata.
                    */
                    //String errorString = '';
                    HDT_WRP_EligibilityCriteria.HDT_WRP_LineError lineError = new HDT_WRP_EligibilityCriteria.HDT_WRP_LineError();
                    for(Database.Error err : dr.getErrors()) {
                        lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                    }
                    saveResponse.errorData.add(lineError);
                }
            }
        }

        if(saveResponse.errorData.size() > 0){
            Database.rollback(sp);
            saveResponse.success = false;
            saveResponse.message = '# ERROR: delete failed';
        } else {
            saveResponse.success = true;
            saveResponse.message = Label.HDT_EligCriteria_DeleteComplete;
        }

        return saveResponse;

    }

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode createDefaultCityZipCodeObj(HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode cityZipCodeObj){
        StaticResource sr = HDT_QR_EligibilityCriteria.getMunicipalitiesStaticResource();
        cityZipCodeObj  = (HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode)JSON.deserialize(sr.Body.toString(), HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode.class);
        return cityZipCodeObj;
    }

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj createMunicipalityNotAvailableObj(HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj municipalityTreeObj, String recordId){
        
        municipalityTreeObj = new HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj();

        try{

            HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode cityZipCodeObj;
            cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.getExistingEligibleMunicipalities(recordId, cityZipCodeObj);

            List<EligibilityCriteria__c> criteria;
            criteria = HDT_QR_EligibilityCriteria.getEligibilityCriteriaSingleRecord(criteria, recordId);


            if(!criteria[0].EligibleForAllCities__c){
                municipalityTreeObj.eligibleForAllCities = false;
                municipalityTreeObj.treeNotAvailableItemList = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();

                HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem treeItemNot;

                for(HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv : cityZipCodeObj.regionList[0].provinceList){

                    if(singleProv.isEnabled){

                        if(singleProv.cityRemoved.size() > 0){

                            treeItemNot = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                            treeItemNot.label = singleProv.label + ' (' + singleProv.value + ')';
                            treeItemNot.name = singleProv.value;
                            treeItemNot.expanded = false;
                            treeItemNot.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();
    
                            HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem nestedTreeNotItem;
                            for(HDT_WRP_EligibilityCriteria.HDT_WRP_City cityItem : singleProv.cityRemoved){
                                nestedTreeNotItem = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                                nestedTreeNotItem.label = cityItem.label + ' (' + cityItem.value + ')';
                                nestedTreeNotItem.name = cityItem.value;
                                nestedTreeNotItem.expanded = false;
                                nestedTreeNotItem.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();
                                treeItemNot.items.add(nestedTreeNotItem);
                            }
    
                            municipalityTreeObj.treeNotAvailableItemList.add(treeItemNot);

                        }

                    } else {
                        treeItemNot = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                        treeItemNot.label = singleProv.label + ' (' + singleProv.value + ')';
                        treeItemNot.name = singleProv.value;
                        treeItemNot.expanded = false;
                        treeItemNot.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();

                        HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem nestedTreeNotItem;
                        nestedTreeNotItem = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                        nestedTreeNotItem.label = 'I comuni di ' + singleProv.label + ' non sono eleggibili';
                        nestedTreeNotItem.name = 'AllCityNotAvailable';
                        nestedTreeNotItem.expanded = false;
                        nestedTreeNotItem.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();
                        treeItemNot.items.add(nestedTreeNotItem);

                        municipalityTreeObj.treeNotAvailableItemList.add(treeItemNot);
                    }

                }

            } else {
                municipalityTreeObj.eligibleForAllCities = true;
                municipalityTreeObj.treeNotAvailableItemList = null;
            }

        } catch (Exception e){
            System.debug(LoggingLevel.DEBUG, '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
            throw new AuraHandledException(e.getMessage());
        }

        System.debug(LoggingLevel.DEBUG, 'municipalityTreeObj serialized: ' + JSON.serialize(municipalityTreeObj));

        return municipalityTreeObj;
    }

}