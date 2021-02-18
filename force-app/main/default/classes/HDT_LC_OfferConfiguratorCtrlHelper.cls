public inherited sharing class HDT_LC_OfferConfiguratorCtrlHelper {
    
    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveTechnicalOffer(List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow> offerList, String productId) {
        System.debug('# saveTechnicalOffer controller helper #');
        System.debug('# offerList size -> ' + offerList.size());

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse();

        Savepoint sp = Database.setSavepoint();

        Product2 pr = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id =: productId  WITH SECURITY_ENFORCED LIMIT 1];

        TechnicalOffer__c tecOff = new TechnicalOffer__c();
        tecOff.Name = '[Offerta] - ' + pr.Name;
        tecOff.Product__c = productId;
        
        try{
            insert tecOff;
        } catch (Exception e){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
            saveResponse.dataError = false;
            return saveResponse;
        }

        List<TechnicalOfferItem__c> itemList = new List<TechnicalOfferItem__c>();
        TechnicalOfferItem__c tecOffItem;

        for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow offerLine : offerList){
            tecOffItem = convertWrapperToObject(tecOffItem, offerLine);
            tecOffItem.TechnicalOffer__c = tecOff.Id;
            itemList.add(tecOffItem);
        }

        saveResponse.errorData = new List<HDT_WRP_TechnicalOffer.HDT_WRP_LineError>();
        saveResponse.errorData = databaseInsert(itemList, saveResponse.errorData);

        if(saveResponse.errorData.size() > 0){
            Database.rollback(sp);
            saveResponse.success = false;
            saveResponse.message = '# ERROR: insert failed';
        } else {
            saveResponse.success = true;
            saveResponse.techOffId = tecOff.Id;
        }
        
        return saveResponse;

    }

    public static List<HDT_WRP_TechnicalOffer.HDT_WRP_LineError> databaseInsert(List<TechnicalOfferItem__c> itemList, List<HDT_WRP_TechnicalOffer.HDT_WRP_LineError> errorData){

        List<Database.SaveResult> insertResults = Database.insert(itemList, false);

        for(Integer n=0; n<insertResults.size(); n++){
            Database.SaveResult sr = insertResults[n];

            if (!sr.isSuccess()) {
                // Operation failed
                String errorString = '';
                HDT_WRP_TechnicalOffer.HDT_WRP_LineError lineError = new HDT_WRP_TechnicalOffer.HDT_WRP_LineError();
                for(Database.Error err : sr.getErrors()) {
                    lineError.rowId = itemList[n].RowId__c;
                    lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                }
                errorData.add(lineError);
            }
        }
   
        return errorData;
    }

    public static HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow convertObjectToWrapper(TechnicalOfferItem__c tempItem, HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow setSingleRow){
        setSingleRow.Id = tempItem.RowId__c;
        setSingleRow.definition = tempItem.Definition__c;
        setSingleRow.type = tempItem.Type__c;
        setSingleRow.m = tempItem.M__c;
        setSingleRow.v = tempItem.V__c;
        setSingleRow.rateType.label = tempItem.FareType__c;
        setSingleRow.rateType.value = tempItem.FareTypeValue__c;
        setSingleRow.infoGroup.label = tempItem.InfoGroup__c;
        setSingleRow.infoGroup.value = tempItem.InfoGroupValue__c;
        setSingleRow.numValue.value = tempItem.NumericValue__c;
        //singleRow.flag.value = (String)tempItem.get('Flag__c');
        setSingleRow.priceCode.label = tempItem.PriceCode__c;
        setSingleRow.priceCode.value = tempItem.PriceCodeValue__c;
        setSingleRow.stringValue.label = tempItem.StringValue__c;
        return setSingleRow;
    }

    public static TechnicalOfferItem__c convertWrapperToObject(TechnicalOfferItem__c tecOffItem, HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow offerLine){
        /*System.debug('# ' + 
        '[id = ' + offerLine.id + '] - ' +
        '[M = ' + offerLine.m + '] - ' +
        '[V = ' + offerLine.v + '] - ' +
        '[rateType = ' + offerLine.rateType.value + '] - ' +
        '[infoGroup = ' + offerLine.infoGroup.value + '] - ' +
        '[numValue = ' + offerLine.numValue.value + '] - ' +
        '[flag = ' + offerLine.flag.value + '] - ' +
        '[priceCode = ' + offerLine.priceCode.value + '] - ' +
        '[stringValue = ' + offerLine.stringValue.value + ']' + 
        '[tecName = ' + offerLine.tecName + ']'
        );*/
        
        tecOffItem = new TechnicalOfferItem__c();
        tecOffItem.RowId__c = offerLine.id;
        tecOffItem.Type__c = offerLine.type;
        tecOffItem.Definition__c = offerLine.definition;
        tecOffItem.V__c = offerLine.v;
        tecOffItem.M__c = offerLine.m;
        tecOffItem.Operand__c = offerLine.tecName;
        tecOffItem.FareType__c = offerLine.rateType.label;//label
        tecOffItem.FareTypeValue__c = offerLine.rateType.value;//value
        tecOffItem.InfoGroup__c = offerLine.infoGroup.label;//label
        tecOffItem.InfoGroupValue__c = offerLine.infoGroup.value;//value
        tecOffItem.NumericValue__c = offerLine.numValue.value;
        tecOffItem.Flag__c = true;//offerLine.flag.value;
        tecOffItem.PriceCode__c = offerLine.priceCode.label;//label
        tecOffItem.PriceCodeValue__c = offerLine.infoGroup.value;//value
        tecOffItem.StringValue__c = offerLine.stringValue.value;
        return tecOffItem;
    }

    public static TechnicalOffer__c queryTechnicalOfferRecord(Id recId){
        TechnicalOffer__c techOff = [
            SELECT Id, Name, (
                    SELECT Id,RowId__c,Type__c,Operand__c, Definition__c, M__c, V__c,TechnicalOffer__c,PriceCodeValue__c,StringValue__c,
                           FareType__c,FareTypeValue__c,InfoGroup__c,InfoGroupValue__c,NumericValue__c,Flag__c,PriceCode__c
                    FROM TechnicalOfferItems__r ORDER BY RowId__c
                )
            FROM TechnicalOffer__c
            WHERE Id =: recId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return techOff;
    }
    
    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse cloneRecordHandler(String recIdToClone, String productId){

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse();

        TechnicalOffer__c newTechOff = new TechnicalOffer__c();
        Savepoint sp = Database.setSavepoint();

        Product2 pr = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id =: productId  WITH SECURITY_ENFORCED LIMIT 1];

        TechnicalOffer__c recToClone = queryTechnicalOfferRecord(recIdToClone);

        newTechOff = recToClone.clone(false, true, false, false);
        newTechOff.Name = '[Offerta] - ' + pr.Name;
        newTechOff.Product__c = productId;

        System.debug('# clone this -> ' + newTechOff);

        try{
            insert newTechOff;
        } catch (Exception e){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
            saveResponse.dataError = false;
            return saveResponse;
        }

        List<TechnicalOfferItem__c> newItemsList = new List<TechnicalOfferItem__c>();
        TechnicalOfferItem__c newItem;
        for(TechnicalOfferItem__c item : recToClone.TechnicalOfferItems__r){
            newItem = new TechnicalOfferItem__c();
            newItem = item.clone(false, true, false, false);
            newItem.TechnicalOffer__c = newTechOff.Id;
            newItemsList.add(newItem);
        }

        saveResponse.errorData = new List<HDT_WRP_TechnicalOffer.HDT_WRP_LineError>();
        saveResponse.errorData = databaseInsert(newItemsList, saveResponse.errorData);

        if(saveResponse.errorData.size() > 0){
            Database.rollback(sp);
            saveResponse.success = false;
            saveResponse.message = '# ERROR: insert failed';
        } else {
            saveResponse.success = true;
            saveResponse.techOffId = newTechOff.Id;
        }

        return saveResponse;

    }

    public static void sendTechOfferToSAP(){
        
    }

    public static Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>> crateComplexMatrix(){

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MatrixConfiguration'  WITH SECURITY_ENFORCED LIMIT 1];
        HDT_WRP_TechnicalOffer.HDT_WRP_MatrixData matrixObj = (HDT_WRP_TechnicalOffer.HDT_WRP_MatrixData)JSON.deserialize(sr.Body.toString(), HDT_WRP_TechnicalOffer.HDT_WRP_MatrixData.class);
        
        Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>> operandMap = new Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>>();
        for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixConfig op : matrixObj.data){
            Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail> fieldDetailMap = new Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>();
            HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail cd;

            for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixDetail s : op.fields){
                cd = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
                cd.value = '';
                cd.label = '';
                cd.relatedTo = (String.isEmpty(s.relatedTo)) ? '' : s.relatedTo;
                cd.enabled = s.enabled;
                fieldDetailMap.put(s.fieldName, cd);
            }
            operandMap.put(op.opName, fieldDetailMap);
        }
        
        return operandMap;
    }

}