public class HDT_LC_OfferConfiguratorController {

    @AuraEnabled
    public static ResponseTecOffer getExistingOffer(String productId) {
        System.debug('### recordId -> ' + productId);

        ResponseTecOffer respObj = new ResponseTecOffer();
        List<TecnicalOffer__c> tecOffList = new List<TecnicalOffer__c>();

        try{
            respObj.success = true;
            respObj.errorMessage = '';
            respObj.data = new TecnicalOfferObj();

            tecOffList = [
                SELECT Id
                FROM TecnicalOffer__c
                WHERE ProductId__c =: productId
            ];

            if(tecOffList != null && tecOffList.size() > 0){
                respObj.data.offerIsPresent = true;
                respObj.data.tecnicalOfferId = tecOffList[0].Id;
            } else {
                respObj.data.offerIsPresent = false;
                respObj.data.tecnicalOfferId = '';            
            }

        } catch (Exception ex){
            respObj.success = false;
            respObj.errorMessage = ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']';
        }

        return respObj;
    }

    @AuraEnabled
    public static ResponseObj saveNewOfferConfigured(String offerJson){
        System.debug('# saveNewOfferConfigured #');
        //System.debug(offerJson);

        ResponseObj responseObj = new ResponseObj();

        try{

            List<OfferObject> offerList = (List<OfferObject>)JSON.deserialize(offerJson, List<OfferObject>.class);

            for(OfferObject obj : offerList){
                System.debug('# obj -> ' + obj);
            }

            responseObj.success = true;
            responseObj.message = 'nothing to declare';

        } catch (Exception ex){
            responseObj.success = false;
            responseObj.message = ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber());
            return responseObj;
        }
        
        
        try{

        } catch (Exception ex){

        }

        return responseObj;

    }

    public class ResponseObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean dataError;
        @AuraEnabled public List<LineError> errorData;
    }

    public class LineError{
        @auraEnabled public String rowId;
        @auraEnabled public String errorMessage;
    }

    public class OfferObject{
        public String id;
        public String definition;
        public Boolean checkUser;
        public FieldDetail amount;
        public FieldDetail grInfo;
        public FieldDetail price;
        public FieldDetail discount;
        public FieldDetail value;
        public FieldDetail stringValue;
        public String tecName;
    }

    public class FieldDetail {
        public String id;
        public String label;
        public Boolean enabled;
    }

    public class ResponseTecOffer {
        @auraEnabled public Boolean success;
        @auraEnabled public String errorMessage;
        @auraEnabled public TecnicalOfferObj data;
    }

    public class TecnicalOfferObj {
        @auraEnabled public Boolean offerIsPresent;
        @auraEnabled public String tecnicalOfferId;
    }

}