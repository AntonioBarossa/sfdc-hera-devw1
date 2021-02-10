public inherited sharing class HDT_LC_OfferConfiguratorController {

    @AuraEnabled(cacheable=true)
    public static String getTableData(String searchTerm){
        String result = '';
        try{
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DataHelper' LIMIT 1];
            result = sr.Body.toString();

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
        return result;
    }

    @AuraEnabled
    public static HDT_WRP_ResponseTecOffer getExistingOffer(String productId) {
        System.debug('### recordId -> ' + productId);

        HDT_WRP_ResponseTecOffer respObj = new HDT_WRP_ResponseTecOffer();
        List<TecnicalOffer__c> tecOffList = new List<TecnicalOffer__c>();

        try{
            respObj.success = true;
            respObj.errorMessage = '';
            respObj.data = new HDT_WRP_TecnicalOfferObj();

            tecOffList = [
                SELECT Id
                FROM TecnicalOffer__c
                WHERE ProductId__c =: productId
                WITH SECURITY_ENFORCED
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
    public static HDT_WRP_MatrixTable getOfferMatrix(){
        HDT_WRP_MatrixTable matrixTable = new HDT_WRP_MatrixTable();

        try{
            matrixTable.success = true;
            matrixTable.message = 'Everithings ok';
            matrixTable.rowList = new List<HDT_WRP_MatrixSingleRow>();

            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MatrixDataInput' LIMIT 1];
            matrixTable.rowList = (List<HDT_WRP_MatrixSingleRow>)JSON.deserialize(sr.Body.toString(), List<HDT_WRP_MatrixSingleRow>.class);

        } catch (Exception e){
            throw new AuraHandledException('# Error -> ' + e.getMessage() + ', at line [' + String.valueOf(e.getLineNumber()) + ']');
        }
        
        return matrixTable;
    }

    @AuraEnabled
    public static HDT_WRP_ResponseObj saveNewOfferConfigured(String offerJson){
        System.debug('# saveNewOfferConfigured #');
        //System.debug(offerJson);

        HDT_WRP_ResponseObj responseObj = new HDT_WRP_ResponseObj();

        try{

            List<HDT_WRP_MatrixSingleRow> offerList = (List<HDT_WRP_MatrixSingleRow>)JSON.deserialize(offerJson, List<HDT_WRP_MatrixSingleRow>.class);

            System.debug('####');
            System.debug(offerList);

            responseObj.success = true;
            responseObj.message = 'nothing to declare';

        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']');
        }
        
        return responseObj;

    }

    @AuraEnabled
    public static String getTechnicalOfferRecords(String recordId){
        String result = '';
        try{
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'offerData' LIMIT 1];
            result = sr.Body.toString();
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
        return result;
    }

    @AuraEnabled
    public static String cloneRecord(String recordId){
        String result = '';
        try{
            //Account a = new Account();
            //a.Id = '';
            //insert a;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
        return result;
    }

    public class HDT_WRP_ResponseObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean dataError;
        @AuraEnabled public List<HDT_WRP_LineError> errorData;
    }

    public class HDT_WRP_LineError{
        @auraEnabled public String rowId;
        @auraEnabled public String errorMessage;
    }

    public class HDT_WRP_ResponseTecOffer {
        @auraEnabled public Boolean success;
        @auraEnabled public String errorMessage;
        @auraEnabled public HDT_WRP_TecnicalOfferObj data;
    }

    public class HDT_WRP_TecnicalOfferObj {
        @auraEnabled public Boolean offerIsPresent;
        @auraEnabled public String tecnicalOfferId;
    }

    public class HDT_WRP_MatrixTable {
        @auraEnabled public Boolean success;
        @auraEnabled public String message;
        @auraEnabled public List<HDT_WRP_MatrixSingleRow> rowList;
    }

    public class HDT_WRP_MatrixSingleRow {
        @auraEnabled public String id;
        @auraEnabled public String definition;
        @auraEnabled public Boolean checkUser;
        @auraEnabled public HDT_WRP_RowDetail amount;
        @auraEnabled public HDT_WRP_RowDetail grInfo;
        @auraEnabled public HDT_WRP_RowDetail price;
        @auraEnabled public HDT_WRP_RowDetail discount;
        @auraEnabled public HDT_WRP_RowDetail value;
        @auraEnabled public HDT_WRP_RowDetail stringValue;
        @auraEnabled public String tecName;
    }

    public class HDT_WRP_RowDetail {
        @auraEnabled public String id;
        @auraEnabled public String label;
        @auraEnabled public Boolean enabled;
    }

}