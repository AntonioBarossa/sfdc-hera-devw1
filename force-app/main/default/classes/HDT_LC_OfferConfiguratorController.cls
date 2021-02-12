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
    public static HDT_WRP_MatrixTable getOfferMatrix(String productId){

        Boolean isMock = true;
        HDT_WRP_MatrixTable matrixTable = new HDT_WRP_MatrixTable();

        try{
            matrixTable.rowList = new List<HDT_WRP_MatrixSingleRow>();

            //HDT_WRP_ProductObj prodObj = (HDT_WRP_ProductObj)JSON.deserialize(productObj, HDT_WRP_ProductObj.class);
            //System.debug('# Product obj -> ' + prodObj);

            if(isMock){
                StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MatrixDataInput' LIMIT 1];
                matrixTable.rowList = (List<HDT_WRP_MatrixSingleRow>)JSON.deserialize(sr.Body.toString(), List<HDT_WRP_MatrixSingleRow>.class);
            } else {
                Map<String, Map<String, HDT_WRP_RowDetail>> complexMap = crateComplexMatrix();
    
                Product2 product = [SELECT Id, Template__c, RateCategory__r.Name FROM Product2 WHERE Id =: productId LIMIT 1];
                
                List<OperandTemplate__c> operands = [
                    SELECT Id, Operands__c, ContractTemplate__c, Typology__c, UnitPrice__c
                    FROM OperandTemplate__c
                    WHERE ContractTemplate__c =: product.Template__c
                ];

                HDT_WRP_MatrixSingleRow singleRow;
                for(OperandTemplate__c singleOperand : operands){
                    Map<String, HDT_WRP_RowDetail> rowDetailMap = complexMap.get(singleOperand.Typology__c);
                    singleRow = new HDT_WRP_MatrixSingleRow();
                    singleRow.tecName = singleOperand.Operands__c;
                    singleRow.infoGroup = rowDetailMap.get('infoGroup');
                    singleRow.value = rowDetailMap.get('NumericalValue');//numericalValue
                    singleRow.price = rowDetailMap.get('PriceCode');//PriceCode
                    singleRow.stringValue = rowDetailMap.get('TextString');//TextString
                    matrixTable.rowList.add(singleRow);
                }
            }

            matrixTable.success = true;
            matrixTable.message = 'Everithings ok';

        } catch (Exception e){
            System.debug('# ERROR -> ' + e.getMessage() + String.valueOf(e.getLineNumber()));
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

    public static Map<String, Map<String, HDT_WRP_RowDetail>> crateComplexMatrix(){

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MatrixConfiguration' LIMIT 1];
        HDT_WRP_MatrixData matrixObj = (HDT_WRP_MatrixData)JSON.deserialize(sr.Body.toString(), HDT_WRP_MatrixData.class);
        
        Map<String, Map<String, HDT_WRP_RowDetail>> operandMap = new Map<String, Map<String, HDT_WRP_RowDetail>>();
        for(HDT_WRP_MatrixConfig op : matrixObj.data){
            Map<String, HDT_WRP_RowDetail> fieldDetailMap = new Map<String, HDT_WRP_RowDetail>();
            HDT_WRP_RowDetail cd;

            for(HDT_WRP_MatrixDetail s : op.fields){
                cd = new HDT_WRP_RowDetail();
                //fieldName
                cd.relatedTo = (String.isEmpty(s.relatedTo)) ? '' : s.relatedTo;
                cd.enabled = s.enabled;
                fieldDetailMap.put(s.fieldName, cd);
            }
            operandMap.put(op.opName, fieldDetailMap);
        }
        
        return operandMap;
    }

    public class HDT_WRP_MatrixData {
        public List<HDT_WRP_MatrixConfig> data;
    }

    public class HDT_WRP_MatrixConfig {
        public String opName;
        public List<HDT_WRP_MatrixDetail> fields;
    }

    public class HDT_WRP_MatrixDetail {
        public String fieldName;
        public Boolean enabled;
        public String relatedTo;
    }

    public class HDT_WRP_ProductObj {
        public String productId;
        public String template;
        public String version;
        public String rateCategory;
        public String productCode;
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
        @auraEnabled public String tecName;
        @auraEnabled public String definition;
        @auraEnabled public Boolean checkUser;
        @auraEnabled public HDT_WRP_RowDetail startDate;
        @auraEnabled public HDT_WRP_RowDetail endDate;
        //@auraEnabled public HDT_WRP_RowDetail list rateType
        @auraEnabled public HDT_WRP_RowDetail infoGroup;
        @auraEnabled public HDT_WRP_RowDetail value;//numericalValue
        //HDT_WRP_RowDetail Boolean Flag
        @auraEnabled public HDT_WRP_RowDetail price;//PriceCode
        @auraEnabled public HDT_WRP_RowDetail stringValue;//TextString
        ///?????
        @auraEnabled public HDT_WRP_RowDetail amount;    
        @auraEnabled public HDT_WRP_RowDetail discount;
    }

    public class HDT_WRP_RowDetail {
        @auraEnabled public String id;
        @auraEnabled public String label;
        @auraEnabled public String relatedTo;
        @auraEnabled public Boolean enabled;
    }

    /*public class HDT_WRP_Fields {
        @auraEnabled public String fieldType;
        @auraEnabled public List<HDT_WRP_FieldDetail> fields;
    }

    public class HDT_WRP_FieldDetail {
        @auraEnabled public String fieldName;
        @auraEnabled public String relatedTo;
        @auraEnabled public Boolean enabled;
    }*/

}