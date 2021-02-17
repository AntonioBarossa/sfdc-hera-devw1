public inherited sharing class HDT_LC_OfferConfiguratorCtrlHelper {
    
    public static TecnicalOffer__c saveTechnicalOffer(List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow> offerList, String productId) {
        System.debug('# saveTechnicalOffer controller helper #');
        System.debug('# offerList size -> ' + offerList.size());

        List<String> errorMessage = new List<String>();

        Savepoint sp = Database.setSavepoint();

        Product2 pr = [SELECT Id, ProductCode FROM Product2 WHERE Id =: productId LIMIT 1];

        TecnicalOffer__c tecOff = new TecnicalOffer__c();
        tecOff.Name = pr.ProductCode;
        tecOff.ProductId__c = productId;
        
        try{
            insert tecOff;
        } catch (Exception e){
            return tecOff;
        }

        List<TecnicalOfferItem__c> itemList = new List<TecnicalOfferItem__c>();
        TecnicalOfferItem__c tecOffItem;

        for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow offerLine : offerList){
            tecOffItem = convertWrapperToObject(tecOffItem, offerLine);
            tecOffItem.TecnicalOfferId__c = tecOff.Id;
            itemList.add(tecOffItem);
        }

        List<Database.SaveResult> insertResults = Database.insert(itemList, false);
        
        for (Database.SaveResult sr : insertResults) {
            if (!sr.isSuccess()) {
                // Operation failed
                String errorString = '';               
                for(Database.Error err : sr.getErrors()) {
                    errorString += 'The following error has occurred: ';                    
                    errorString += err.getStatusCode() + ': ' + err.getMessage();
                    errorString += ' on field: ' + err.getFields();
                    errorMessage.add(errorString);
                }
            }
        }


        if(errorMessage.size() > 0){
            Database.rollback(sp);
        }
        
        return tecOff;

    }

    public static TecnicalOfferItem__c convertWrapperToObject(TecnicalOfferItem__c tecOffItem, HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow offerLine){
        System.debug('# ' + 
        '[id = ' + offerLine.id + '] - ' +
        '[M = ' + offerLine.m + '] - ' +
        '[V = ' + offerLine.v + '] - ' +
        //'[startDate = ' + offerLine.startDate.value + '] - ' +
        //'[endDate = ' + offerLine.endDate.value + '] - ' +
        '[rateType = ' + offerLine.rateType.value + '] - ' +
        '[infoGroup = ' + offerLine.infoGroup.value + '] - ' +
        '[numValue = ' + offerLine.numValue.value + '] - ' +
        '[flag = ' + offerLine.flag.value + '] - ' +
        '[priceCode = ' + offerLine.priceCode.value + '] - ' +
        '[stringValue = ' + offerLine.stringValue.value + ']' + 
        '[tecName = ' + offerLine.tecName + ']'
        );
        
        tecOffItem = new TecnicalOfferItem__c();
        tecOffItem.RowId__c = offerLine.id;
        tecOffItem.Type__c = offerLine.type;
        tecOffItem.Definition__c = offerLine.definition;
        tecOffItem.V__c = offerLine.v;
        tecOffItem.M__c = offerLine.m;
        tecOffItem.Operand__c = offerLine.tecName;
        //tecOffItem.Duration__c = offerLine.startDate.value;
        //tecOffItem.Delay__c = offerLine.endDate.value;
        tecOffItem.FareType__c = offerLine.rateType.value;
        tecOffItem.InfoGroup__c = offerLine.infoGroup.value;
        tecOffItem.NumericValue__c = offerLine.numValue.value;
        tecOffItem.Flag__c = true;//offerLine.flag.value;
        tecOffItem.PriceCode__c = offerLine.priceCode.value;
        tecOffItem.StringValue__c = offerLine.stringValue.value;
        return tecOffItem;
    }

    public static TecnicalOffer__c queryTechnicalOfferRecord(Id recId){
        TecnicalOffer__c techOff = [
            SELECT Id, Name, (
                    SELECT Id,RowId__c,Type__c,Operand__c,Duration__c,Delay__c, Definition__c, M__c, V__c,
                           FareType__c,InfoGroup__c,NumericValue__c,Flag__c,PriceCode__c,StringValue__c,TecnicalOfferId__c
                    FROM TechnicalOfferItems__r
                )
            FROM TecnicalOffer__c
            WHERE Id =: recId
            LIMIT 1
        ];
        return techOff;
    }
    
    public static Id cloneRecordHandler(String recIdToClone, String productId){

        List<String> errorMessage = new List<String>();
        TecnicalOffer__c newTechOff = new TecnicalOffer__c();
        Savepoint sp = Database.setSavepoint();

        TecnicalOffer__c recToClone = queryTechnicalOfferRecord(recIdToClone);

        newTechOff = recToClone.clone(false, true, false, false);
        newTechOff.Name += '_Clone';
        newTechOff.ProductId__c = productId;

        System.debug('# clone this -> ' + newTechOff);

        try{
            insert newTechOff;
        } catch (Exception e){
            return newTechOff.Id;
        }

        List<TecnicalOfferItem__c> newItemsList = new List<TecnicalOfferItem__c>();
        TecnicalOfferItem__c newItem;
        for(TecnicalOfferItem__c item : recToClone.TechnicalOfferItems__r){
            newItem = new TecnicalOfferItem__c();
            newItem = item.clone(false, true, false, false);
            newItem.TecnicalOfferId__c = newTechOff.Id;
            newItemsList.add(newItem);
        }

        List<Database.SaveResult> insertResults = Database.insert(newItemsList, false);
        
        for (Database.SaveResult sr : insertResults) {
            if (!sr.isSuccess()) {
                // Operation failed
                String errorString = '';               
                for(Database.Error err : sr.getErrors()) {
                    errorString += 'The following error has occurred: ';                    
                    errorString += err.getStatusCode() + ': ' + err.getMessage();
                    errorString += ' on field: ' + err.getFields();
                    errorMessage.add(errorString);
                }
            }
        }


        if(errorMessage.size() > 0){
            Database.rollback(sp);
        }

        return newTechOff.Id;

    }

    public static void sendTechOfferToSAP(){
        
    }

    public static Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>> crateComplexMatrix(){

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MatrixConfiguration' LIMIT 1];
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