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
                SELECT Id, Name, AreaCode__c, JSON_Code__c
                FROM EligibleMunicipality__c
                WHERE EligibilityCriteria__c =: recordId
            ];

            //HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode CityZipCodeObj;
            //StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Municipalities' WITH SECURITY_ENFORCED LIMIT 1];
            //CityZipCodeObj  = (HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode)JSON.deserialize(sr.Body.toString(), HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode.class);

            HDT_WRP_EligibilityCriteria.HDT_WRP_TreeObjItem treeItem;
            for(EligibleMunicipality__c muni : muniList){

                HDT_WRP_EligibilityCriteria.HDT_WRP_Province singleProv  = (HDT_WRP_EligibilityCriteria.HDT_WRP_Province)JSON.deserialize(muni.JSON_Code__c, HDT_WRP_EligibilityCriteria.HDT_WRP_Province.class);

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
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode getCityZipCodeObj(String regionCode){

        HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode CityZipCodeObj;

        try{
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Municipalities' WITH SECURITY_ENFORCED LIMIT 1];

            CityZipCodeObj  = (HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode)JSON.deserialize(sr.Body.toString(), HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode.class);

            CityZipCodeObj.success = true;
            CityZipCodeObj.message = '';

            System.debug('# result -> ' +  CityZipCodeObj.regionList[0].provinceList);

        } catch (Exception e){
            System.debug('# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
            throw new AuraHandledException(e.getMessage());
        } 
        return CityZipCodeObj;

    }

    @AuraEnabled
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion getExistingCriteria() {
        HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion recObj = new HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion();

        try{
            recObj.success = true;
            recObj.recIsPresent = false;
            recObj.eligibilityId = '';
        } catch (Exception e){
            recObj.success = false;
            recObj.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return recObj;
    }

    @AuraEnabled
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveEligibilityCriteria(String productId, String dataReceived) {

        System.debug('### productId ' + productId);
        System.debug('### dataReceived: ' + dataReceived);

        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse();

        try{

            List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province> provinceList = (List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province>)JSON.deserialize(dataReceived, List<HDT_WRP_EligibilityCriteria.HDT_WRP_Province>.class);

            System.debug('# provinceList size -> ' + provinceList.size());

            saveResponse = HDT_LC_EligibilityCriteriaCtrlHelper.saveEligibilityCriteriaHelper(provinceList, productId);

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

}