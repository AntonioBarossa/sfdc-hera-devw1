public inherited sharing class HDT_LC_EligibilityCriteriaController {

    @AuraEnabled
    public static HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion getExistingCriterion() {
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
    public static ResponseObject saveCityEligibility(String productId, String dataReceived) {

        System.debug('### productId ' + productId);
        System.debug('### dataReceived: ' + dataReceived);

        ResponseObject resp = new ResponseObject();

        try{

            List<DataReceived> dataList = (List<DataReceived>)JSON.deserialize(dataReceived, List<DataReceived>.class);
            //List<CityEligible__c> cityList = new List<CityEligible__c>();

            //CityEligible__c c;
            //for(DataReceived d : dataList){
            //    System.debug('# ' + d.id + ' - ' + d.label + ' - ' + d.value);
            //    c = new CityEligible__c();
            //    c.Name = d.label;
            //    c.ZipCode__c = d.value;
            //    c.Product2Id__c = productId;
            //    cityList.add(c);
            //}

            //insert cityList;

            resp.success = true;
            resp.message = '';

        } catch (Exception ex){
            resp.success = false;
            resp.message = ex.getMessage() + '; at line [' + String.valueOf(ex.getLineNumber()) + ']';
        }

        return resp;
    }

    public class ResponseObject {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }


    public class DataReceived {
        public String id;
        public String label;
        public String value;
    }

}