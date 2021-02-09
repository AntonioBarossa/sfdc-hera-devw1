public class HDT_LC_OfferConfiguratorController {

    @AuraEnabled(cacheable=true)
    public static String getTableData(String searchTerm){
        System.debug('# getTableData -> ' + searchTerm);

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DataHelper' LIMIT 1];

        return sr.Body.toString();
    }

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
    public static MatrixTable getOfferMatrix(){
        MatrixTable matrixTable = new MatrixTable();

        try{
            matrixTable.success = true;
            matrixTable.message = 'Everithings ok';
            matrixTable.rowList = new List<MatrixSingleRow>();

            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MatrixDataInput' LIMIT 1];
            matrixTable.rowList = (List<MatrixSingleRow>)JSON.deserialize(sr.Body.toString(), List<MatrixSingleRow>.class);

        } catch (Exception e){
            matrixTable.success = false;
            matrixTable.message = '# Error -> ' + e.getMessage() + ', at line [' + String.valueOf(e.getLineNumber()) + ']';
        }
        
        return matrixTable;
    }

    @AuraEnabled
    public static ResponseObj saveNewOfferConfigured(String offerJson){
        System.debug('# saveNewOfferConfigured #');
        //System.debug(offerJson);

        ResponseObj responseObj = new ResponseObj();

        try{

            List<MatrixSingleRow> offerList = (List<MatrixSingleRow>)JSON.deserialize(offerJson, List<MatrixSingleRow>.class);

            System.debug('####');
            System.debug(offerList);

            responseObj.success = true;
            responseObj.message = 'nothing to declare';

        } catch (Exception ex){
            responseObj.success = false;
            responseObj.message = ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber());
            return responseObj;
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

    /*public class OfferObject{
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
    }*/

    public class ResponseTecOffer {
        @auraEnabled public Boolean success;
        @auraEnabled public String errorMessage;
        @auraEnabled public TecnicalOfferObj data;
    }

    public class TecnicalOfferObj {
        @auraEnabled public Boolean offerIsPresent;
        @auraEnabled public String tecnicalOfferId;
    }

    public class MatrixTable {
        @auraEnabled public Boolean success;
        @auraEnabled public String message;
        @auraEnabled public List<MatrixSingleRow> rowList;
    }

    public class MatrixSingleRow {
        @auraEnabled public String id;
        @auraEnabled public String definition;
        @auraEnabled public Boolean checkUser;
        @auraEnabled public RowDetail amount;
        @auraEnabled public RowDetail grInfo;
        @auraEnabled public RowDetail price;
        @auraEnabled public RowDetail discount;
        @auraEnabled public RowDetail value;
        @auraEnabled public RowDetail stringValue;
        @auraEnabled public String tecName;
    }

    public class RowDetail {
        @auraEnabled public String id;
        @auraEnabled public String label;
        @auraEnabled public Boolean enabled;
    }

}