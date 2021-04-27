public inherited sharing class HDT_LC_EligibilityCriteriaController {

    @AuraEnabled
    public static String cloneEligibilityCriteriaRecord(String recIdToClone, String productId){
        
        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();

        try{
            saveResponse = HDT_LC_EligibilityCriteriaCtrlHelper.cloneEligibilityCriteriaHelper(recIdToClone, productId);

            if(!saveResponse.success){
                System.debug('# on clone controller #');
                for(HDT_WRP_EligibilityCriteria.HDT_WRP_LineError le : saveResponse.errorData){
                    System.debug('# ' + le);
                }
            }

        } catch (Exception e){
            System.debug('# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
            throw new AuraHandledException(e.getMessage());
        } 
        return saveResponse.criteriaId;
    }

    @AuraEnabled
    public static List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem> getEligibilityCriteriaRecord(String recordId){

        System.debug('# search this criteria > ' + recordId);

        List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem> treeItemList = new List<HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem>();

        try{

            List<EligibleMunicipality__c> muniList = new List<EligibleMunicipality__c>();
            muniList = [
                SELECT Id, Name, AreaCode__c, JSONCode__c
                FROM EligibleMunicipality__c
                WHERE EligibilityCriteria__c =: recordId
                WITH SECURITY_ENFORCED
            ];

            //HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode cityZipCodeObj;
            //StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Municipalities' WITH SECURITY_ENFORCED LIMIT 1];
            //cityZipCodeObj  = (HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode)JSON.deserialize(sr.Body.toString(), HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode.class);

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
                treeItemList.add(treeItem);
            }

        } catch (Exception e){
            System.debug('# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
            throw new AuraHandledException(e.getMessage());
        }

        System.debug(JSON.serialize(treeItemList));

        return treeItemList;
    }

    @AuraEnabled
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode getCityZipCodeObj(String regionCode, String eligibilityId){

        System.debug('# eligibilityId >>> ' + eligibilityId);

        HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode cityZipCodeObj;

        try{

            if(String.isEmpty(eligibilityId)){
                // eligibilityId IS NULL, so get all Municipalities code
                StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Municipalities' WITH SECURITY_ENFORCED LIMIT 1];

                cityZipCodeObj  = (HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode)JSON.deserialize(sr.Body.toString(), HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode.class);
    
                cityZipCodeObj.success = true;
                cityZipCodeObj.message = '';
            } else {
                // eligibilityId IS NOT NULL, so get eligibility database records
                //cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.getExistingEligibleMunicipalities(eligibilityId, cityZipCodeObj);

                // eligibilityId IS NOT NULL, so get eligibility database records ---> returns 2 list: cityAvailable and cityRemoved 
                cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.getExistingEligibleMunicipalities2(eligibilityId, cityZipCodeObj);

                if(!cityZipCodeObj.success){
                    return cityZipCodeObj;
                }

                cityZipCodeObj.success = true;
                cityZipCodeObj.message = '';
            }

            System.debug('# result -> ' +  cityZipCodeObj.regionList[0].provinceList);

        } catch (Exception e){
            System.debug('# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
            throw new AuraHandledException(e.getMessage());
        } 
        return cityZipCodeObj;

    }

    @AuraEnabled
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion getExistingCriteria(String productId) {

        System.debug('## >> ' + productId);

        HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion recObj = new HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion();

        try{
            recObj.success = true;

            List<EligibilityCriteria__c> eliCrit = new List<EligibilityCriteria__c>();
            eliCrit = [
                SELECT Id
                FROM EligibilityCriteria__c
                WHERE Product__c = :productId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            System.debug('## >> ' + eliCrit.size());

            if(eliCrit != null && eliCrit.size() > 0){
                System.debug('## >> ' + eliCrit[0].Id);
                recObj.recIsPresent = true;
                recObj.eligibilityId = eliCrit[0].Id;
            } else {
                recObj.recIsPresent = false;
                recObj.eligibilityId = '';      
            }

        } catch (Exception e){
            recObj.success = false;
            recObj.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return recObj;
    }

    @AuraEnabled
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveEligibilityCriteria(String productId, String record, String dataReceived) {

        System.debug('### productId ' + productId);
        System.debug('### record: ' + record);
        //System.debug('### dataReceived: ' + dataReceived);

        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();

        try{

            List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province> provinceList = (List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province>)JSON.deserialize(dataReceived, List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province>.class);

            System.debug('# provinceList size -> ' + provinceList.size());

            saveResponse = HDT_LC_EligibilityCriteriaCtrlHelper.saveEligibilityCriteriaHelper(productId, record, provinceList);
            //HDT_LC_EligibilityCriteriaCtrlHelper.updateEligibilityCriteria(productId, true);

            if(!saveResponse.success){
                System.debug('# on controller #');
                for(HDT_WRP_EligibilityCriteria.HDT_WRP_LineError le : saveResponse.errorData){
                    System.debug('# ' + le);
                }
            }

        } catch (Exception ex){
            saveResponse.success = false;
            saveResponse.message = ex.getMessage() + '; at line [' + String.valueOf(ex.getLineNumber()) + ']';
        }

        return saveResponse;
    }

    @AuraEnabled
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse deleteEligibilityCriteria(String productId, String eligibilityId){
        
        System.debug('# deleteEligibilityCriteria >>> productId: ' + productId + ' - >>> eligibilityId: ' + eligibilityId);

        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse;

        try{

            List<EligibilityCriteria__c> criteriaListToDelete = new List<EligibilityCriteria__c>();
            criteriaListToDelete = [
                SELECT Id
                FROM EligibilityCriteria__c
                WHERE Id =: eligibilityId AND Product__c = :productId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if(criteriaListToDelete.size()>0){
                saveResponse = HDT_LC_EligibilityCriteriaCtrlHelper.deleteEligibilityCriteriaHelper(criteriaListToDelete, saveResponse);
                //HDT_LC_EligibilityCriteriaCtrlHelper.updateEligibilityCriteria(productId, false);
            }

        } catch (Exception ex){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + ex.getMessage() + '; at line [' + String.valueOf(ex.getLineNumber()) + ']';
            throw new AuraHandledException(ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']');
        }
        
        return saveResponse;
    }

}