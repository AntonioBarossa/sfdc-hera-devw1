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
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj getEligibilityCriteriaRecord(String recordId){

        System.debug('# search this criteria > ' + recordId);

        HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj municipalityTreeObj;

        //municipalityTreeObj = HDT_LC_EligibilityCriteriaCtrlHelper.createMunicipalityTreeObj(municipalityTreeObj, recordId);
        //municipalityTreeObj = HDT_LC_EligibilityCriteriaCtrlHelper.createMunicipalityTreeCompleteObj(municipalityTreeObj, recordId);
        municipalityTreeObj = HDT_LC_EligibilityCriteriaCtrlHelper.createMunicipalityNotAvailableObj(municipalityTreeObj, recordId);

        return municipalityTreeObj;
    }

    @AuraEnabled
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode getCityZipCodeObj(String regionCode, String eligibilityId){

        System.debug('# eligibilityId >>> ' + eligibilityId);

        HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode cityZipCodeObj;

        try{
            
            if(String.isEmpty(eligibilityId)){
                // eligibilityId IS NULL, so get all Municipalities code
                //StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Municipalities' WITH SECURITY_ENFORCED LIMIT 1];
                //cityZipCodeObj  = (HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode)JSON.deserialize(sr.Body.toString(), HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode.class);
                cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.createDefaultCityZipCodeObj(cityZipCodeObj);
                cityZipCodeObj.isEditable = true;
                cityZipCodeObj.success = true;
                cityZipCodeObj.message = '';
            } else {

                List<EligibilityCriteria__c> criteria;
                criteria = HDT_QR_EligibilityCriteria.getEligibilityCriteriaSingleRecord(criteria, eligibilityId);

                if(criteria[0].EligibleForAllCities__c){
                    cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.createDefaultCityZipCodeObj(cityZipCodeObj);
                } else {
                    // eligibilityId IS NOT NULL, so get eligibility database records
                    //cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.getExistingEligibleMunicipalities(eligibilityId, cityZipCodeObj);

                    // eligibilityId IS NOT NULL, so get eligibility database records ---> returns 2 list: cityAvailable and cityRemoved 
                    cityZipCodeObj = HDT_LC_EligibilityCriteriaCtrlHelper.getExistingEligibleMunicipalities2(eligibilityId, cityZipCodeObj);

                    if(!cityZipCodeObj.success){
                        return cityZipCodeObj;
                    }

                }

                if(String.isEmpty(criteria[0].Product__r.Status__c) || criteria[0].Product__r.Status__c.equalsIgnoreCase('Vendibile')){
                    cityZipCodeObj.isEditable = false;
                } else {
                    cityZipCodeObj.isEditable = true;
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

            List<EligibilityCriteria__c> eliCrit;
            eliCrit = HDT_QR_EligibilityCriteria.getEligibilityCriteriaByProductId(eliCrit, productId);

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

            //List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province> provinceList = (List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province>)JSON.deserialize(dataReceived, List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province>.class);
            HDT_WRP_EligibilityCriteria.HDT_WRP_Region obj = (HDT_WRP_EligibilityCriteria.HDT_WRP_Region)JSON.deserialize(dataReceived, HDT_WRP_EligibilityCriteria.HDT_WRP_Region.class);
            
            System.debug('# provinceList size -> ' + obj.provinceList.size());

            saveResponse = HDT_LC_EligibilityCriteriaCtrlHelper.saveEligibilityCriteriaHelper(productId, record, obj);
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

            List<EligibilityCriteria__c> criteriaListToDelete;
            criteriaListToDelete = HDT_QR_EligibilityCriteria.getEligibilityCriteriaByIdAndProductId(criteriaListToDelete, eligibilityId, productId);

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