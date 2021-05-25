public inherited sharing class HDT_LC_EligibilityCriteriaCtrlHelper {

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveEligibilityCriteriaHelper(String productId, String record, HDT_WRP_EligibilityCriteria.HDT_WRP_Region obj){
        //List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province> provinceList
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
               upsert criteria;
           } else {
               saveResponse.success = false;
               saveResponse.message = '# ERROR: you don\'t have permission on this obj';
               saveResponse.dataError = false;
               return saveResponse;                
           }

        } catch (Exception e){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
            saveResponse.dataError = false;
            return saveResponse;
        }

        if(!criteria.EligibleForAllCities__c){

            Boolean deleteResponse = handleRecordDelete(isUpsert, criteria.Id);

            if(!deleteResponse){
                saveResponse.success = false;
                saveResponse.message = '# ERROR: delete error';
                return saveResponse;
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
        } else {

            Boolean deleteResponse = handleRecordDelete(isUpsert, criteria.Id);

            if(!deleteResponse){
                saveResponse.success = false;
                saveResponse.message = '# ERROR: delete error';
                return saveResponse;
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

        System.debug('# clone this -> ' + newCriteria);

        try{
            //insert newCriteria;
            SObjectType objtype = Schema.getGlobalDescribe().get('EligibilityCriteria__c');
            Schema.DescribeSObjectResult objRes = objtype.getDescribe();
     
            if(objRes.isCreateable()){
                insert newCriteria;
            } else {
                saveResponse.success = false;
                saveResponse.message = '# ERROR: you don\'t have permission on this obj';
                saveResponse.dataError = false;
                return saveResponse;                
            }

        } catch (Exception e){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
            saveResponse.dataError = false;
            return saveResponse;
        }

        if(!crtiteriaToClone.EligibleForAllCities__c){
            List<EligibleMunicipality__c> newItemsList = new List<EligibleMunicipality__c>();
            EligibleMunicipality__c newItem;
            for(EligibleMunicipality__c itemToClone : crtiteriaToClone.Comuni_Eleggibili__r){
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
                    String errorString = '';
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

    public static Map<String, Set<String>> deserializeUntypedMethod(Map<String, Set<String>> existingMuniMap, List<EligibleMunicipality__c> muniList){
        String jsonInput = '{';

        for(Integer n=0; n < muniList.size(); n++){
            existingMuniMap.put(muniList[n].AreaCode__c, new Set<String>());
            jsonInput += '"' + muniList[n].Id + '":';
            jsonInput += muniList[n].JSONCode__c;
            if((n+1) < muniList.size()){
                jsonInput += ',';
            }
        }
        jsonInput += '}';
        
        Map<String, Object> m =  (Map<String, Object>)JSON.deserializeUntyped(jsonInput);

        for(String k : m.keySet()){
             
            Map<String, Object> objMap = (Map<String, Object>)m.get(k);
            List<Object> cityAvailable = (List<Object>)objMap.get('cityAvailable');
            String areaCode = String.valueOf(objMap.get('value'));

            Set<String> tempSet = existingMuniMap.get(areaCode);
            for(Object city : cityAvailable){
                Map<String, Object> cityMap = (Map<String, Object>)city;
                tempSet.add(String.valueOf(cityMap.get('value')));
            }
            existingMuniMap.put(areaCode, tempSet);

        }

        return existingMuniMap;

    }

    public static Map<String, Set<String>> deserializeMethod(Map<String, Set<String>> existingMuniMap, List<EligibleMunicipality__c> muniList){
            HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv;
            for(EligibleMunicipality__c muni : muniList){
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

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode getExistingEligibleMunicipalities2(String eligibilityId, HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode cityZipCodeObj){

        System.debug('# getExistingEligibleMunicipalities2 > ' + eligibilityId);

        Map<String, Set<String>> existingMuniMap = new Map<String, Set<String>>();

        cityZipCodeObj = new HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode();
        List<EligibleMunicipality__c> muniList;
        List<EligibilityCriteria__c> criteria;

        muniList = HDT_QR_EligibilityCriteria.getEligibleMunicipalityByCriteriaId(muniList, eligibilityId);
        criteria = HDT_QR_EligibilityCriteria.getEligibilityCriteriaSingleRecord(criteria, eligibilityId);

        try{            


            //+++++++++++++++++++++++++++++
            existingMuniMap = deserializeUntypedMethod(existingMuniMap, muniList);

            //+++++++++++++++++++++++++++++
            //existingMuniMap = deserializeMethod(existingMuniMap, muniList);

            cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.createDefaultCityZipCodeObj(cityZipCodeObj);
            cityZipCodeObj.regionList[0].eligibleForAllCities = criteria[0].EligibleForAllCities__c;

            for(HDT_WRP_EligibilityCriteria.HDT_WRP_Province prov : cityZipCodeObj.regionList[0].provinceList){

                if(existingMuniMap.containsKey(prov.value)){
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

                    //System.debug('>>> cityAvailable: ' + prov.cityAvailable.size());
                    //System.debug('>>> cityRemoved: ' + prov.cityRemoved.size());

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

    /*public static HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode getExistingEligibleMunicipalities(String eligibilityId, HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode cityZipCodeObj){

        System.debug('# getExistingEligibleMunicipalities > ' + eligibilityId);
        cityZipCodeObj = new HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode();
        try{
            List<EligibleMunicipality__c> muniList = new List<EligibleMunicipality__c>();
            muniList = [
                SELECT Id, Name, AreaCode__c, JSONCode__c
                FROM EligibleMunicipality__c
                WHERE EligibilityCriteria__c =: eligibilityId
                WITH SECURITY_ENFORCED
            ];
            
            
            cityZipCodeObj.regionList = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_Region>();
            HDT_WRP_EligibilityCriteria.HDT_WRP_Region singleRegion = new HDT_WRP_EligibilityCriteria.HDT_WRP_Region();
            singleRegion.regionName = 'EmiliaRomagna';
            singleRegion.regionCode = 'EMR';
            singleRegion.provinceList = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province>();

            HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv;
            for(EligibleMunicipality__c muni : muniList){
                singleProv = new HDT_WRP_EligibilityCriteria.HDT_WRP_Province();
                singleProv = (HDT_WRP_EligibilityCriteria.HDT_WRP_Province)JSON.deserialize(muni.JSONCode__c, HDT_WRP_EligibilityCriteria.HDT_WRP_Province.class);
                singleRegion.provinceList.add(singleProv);
            }
            cityZipCodeObj.regionList.add(singleRegion);
            cityZipCodeObj.success = true;
            cityZipCodeObj.message = '';
        } catch (Exception e){
            cityZipCodeObj.success = false;
            cityZipCodeObj.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return cityZipCodeObj;

    }*/

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
                    String errorString = '';
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
            saveResponse.message = 'Criterio eliminato correttamente';
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
            cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.getExistingEligibleMunicipalities2(recordId, cityZipCodeObj);

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
            System.debug('# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
            throw new AuraHandledException(e.getMessage());
        }

        System.debug(JSON.serialize(municipalityTreeObj));

        return municipalityTreeObj;
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

    /*public static HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj createMunicipalityTreeObj(HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj municipalityTreeObj, String recordId){
        
        municipalityTreeObj = new HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj();

        try{

            List<EligibleMunicipality__c> muniList;
            List<EligibilityCriteria__c> criteria;
            muniList = HDT_QR_EligibilityCriteria.getEligibleMunicipalityByCriteriaId(muniList, recordId);
            criteria = HDT_QR_EligibilityCriteria.getEligibilityCriteriaSingleRecord(criteria, recordId);


            if(!criteria[0].EligibleForAllCities__c){
                municipalityTreeObj.eligibleForAllCities = false;
                municipalityTreeObj.treeItemList = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();

                HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem treeItem;
                for(EligibleMunicipality__c muni : muniList){

                    HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv  = (HDT_WRP_EligibilityCriteria.HDT_WRP_Province)JSON.deserialize(muni.JSONCode__c, HDT_WRP_EligibilityCriteria.HDT_WRP_Province.class);

                    treeItem = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                    treeItem.label = singleProv.label + ' (' + singleProv.value + ')';
                    treeItem.name = singleProv.value;
                    treeItem.expanded = false;
                    treeItem.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();

                    HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem nestedTreeItem;
                    for(HDT_WRP_EligibilityCriteria.HDT_WRP_City cityItem : singleProv.cityAvailable){
                        nestedTreeItem = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                        nestedTreeItem.label = cityItem.label + ' (' + cityItem.value + ')';
                        nestedTreeItem.name = cityItem.value;
                        nestedTreeItem.expanded = false;
                        nestedTreeItem.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();
                        treeItem.items.add(nestedTreeItem);
                    }
                    municipalityTreeObj.treeItemList.add(treeItem);
                }
            } else {
                municipalityTreeObj.eligibleForAllCities = true;
                municipalityTreeObj.treeItemList = null;
            }

        } catch (Exception e){
            System.debug('# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
            throw new AuraHandledException(e.getMessage());
        }

        System.debug(JSON.serialize(municipalityTreeObj));

        return municipalityTreeObj;
    }

    public static HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj createMunicipalityTreeCompleteObj(HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj municipalityTreeObj, String recordId){
        
        municipalityTreeObj = new HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj();

        try{

            HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode cityZipCodeObj;
            cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.getExistingEligibleMunicipalities2(recordId, cityZipCodeObj);

            List<EligibilityCriteria__c> criteria;
            criteria = HDT_QR_EligibilityCriteria.getEligibilityCriteriaSingleRecord(criteria, recordId);


            if(!criteria[0].EligibleForAllCities__c){
                municipalityTreeObj.eligibleForAllCities = false;
                municipalityTreeObj.treeItemList = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();
                municipalityTreeObj.treeNotAvailableItemList = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();

                HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem treeItem;
                HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem treeItemNot;

                for(HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv : cityZipCodeObj.regionList[0].provinceList){

                    if(singleProv.isEnabled){
                        treeItem = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                        treeItem.label = singleProv.label + ' (' + singleProv.value + ')';
                        treeItem.name = singleProv.value;
                        treeItem.expanded = false;
                        treeItem.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();

                        HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem nestedTreeItem;
                        for(HDT_WRP_EligibilityCriteria.HDT_WRP_City cityItem : singleProv.cityAvailable){
                            nestedTreeItem = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                            nestedTreeItem.label = cityItem.label + ' (' + cityItem.value + ')';
                            nestedTreeItem.name = cityItem.value;
                            nestedTreeItem.expanded = false;
                            nestedTreeItem.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();
                            treeItem.items.add(nestedTreeItem);
                        }

                        municipalityTreeObj.treeItemList.add(treeItem);

                        if(singleProv.cityRemoved.size()>0){

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
                       treeItem = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                       treeItem.label = singleProv.label + ' (' + singleProv.value + ')';
                       treeItem.name = singleProv.value;
                       treeItem.expanded = false;
                       treeItem.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();

                       HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem nestedTreeItem;
                       for(HDT_WRP_EligibilityCriteria.HDT_WRP_City cityItem : singleProv.cityAvailable){
                           nestedTreeItem = new HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem();
                           nestedTreeItem.label = cityItem.label + ' (' + cityItem.value + ')';
                           nestedTreeItem.name = cityItem.value;
                           nestedTreeItem.expanded = false;
                           nestedTreeItem.items = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();
                           treeItem.items.add(nestedTreeItem);
                       }

                       municipalityTreeObj.treeItemList.add(treeItem);
                    }

                }

            } else {
                municipalityTreeObj.eligibleForAllCities = true;
                municipalityTreeObj.treeItemList = null;
            }

        } catch (Exception e){
            System.debug('# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
            throw new AuraHandledException(e.getMessage());
        }

        System.debug(JSON.serialize(municipalityTreeObj));

        return municipalityTreeObj;
    }*/

}