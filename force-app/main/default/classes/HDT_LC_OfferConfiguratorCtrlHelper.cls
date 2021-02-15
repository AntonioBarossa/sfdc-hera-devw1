public inherited sharing class HDT_LC_OfferConfiguratorCtrlHelper {
    
    public static TecnicalOffer__c saveTechnicalOffer(List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow> offerList, String productId) {
        System.debug('# saveTechnicalOffer controller helper #');
        System.debug('# offerList size -> ' + offerList.size());

        List<sObject> objects = new List<sObject>();
        String extId = String.valueOf(datetime.now().getTime());
        TecnicalOffer__c tecOff;
        List<TecnicalOfferItem__c> itemList = new List<TecnicalOfferItem__c>();
        TecnicalOfferItem__c tecOffItem;
        for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow offerLine : offerList){
            System.debug('# ' + 
            '[id = ' + offerLine.id + '] - ' +
            '[tecName = ' + offerLine.tecName + '] - ' +
            '[startDate = ' + offerLine.startDate.value + '] - ' +
            '[endDate = ' + offerLine.endDate.value + '] - ' +
            '[rateType = ' + offerLine.rateType.value + '] - ' +
            '[infoGroup = ' + offerLine.infoGroup.value + '] - ' +
            '[numValue = ' + offerLine.numValue.value + '] - ' +
            '[flag = ' + offerLine.flag.value + '] - ' +
            '[priceCode = ' + offerLine.priceCode.value + '] - ' +
            '[stringValue = ' + offerLine.stringValue.value + ']');

            tecOffItem = new TecnicalOfferItem__c();
            tecOffItem.RowId__c = offerLine.id;
            tecOffItem.Type__c = offerLine.type;
            tecOffItem.Operand__c = offerLine.tecName;
            tecOffItem.Duration__c = offerLine.startDate.value;
            tecOffItem.Delay__c = offerLine.endDate.value;
            tecOffItem.FareType__c = offerLine.rateType.value;
            tecOffItem.InfoGroup__c = offerLine.infoGroup.value;
            tecOffItem.NumericValue__c = offerLine.numValue.value;
            tecOffItem.Flag__c = true;//offerLine.flag.value;
            tecOffItem.PriceCode__c = offerLine.priceCode.value;
            tecOffItem.StringValue__c = offerLine.stringValue.value;
            //tecOffItem.TecnicalOfferId__c = tecOff.Id;

            //this record is used to link quote line item to quote
            TecnicalOffer__c objReference = new TecnicalOffer__c();
            objReference.ExtId__c = extId;
            tecOffItem.TecnicalOfferId__r = objReference;
            objects.add(tecOffItem);
        }

        tecOff = new TecnicalOffer__c();
        tecOff.extId__c = extId;
        tecOff.Name = 'TechnicalOffer';
        tecOff.ProductId__c = productId;
        objects.add(tecOff);

        //insert tecOff;

        //use this example
        /*

        List<Database.SaveResult> updateResults = Database.update(recordRetrieved, false);
        CheckResponse crUpdate;
        joUpdate.CheckResponseList = new List<CheckResponse>();
        for (Integer i=0;i<updateResults.size();i++) {
            if (!updateResults.get(i).isSuccess()) {
                Database.Error error = updateResults.get(i).getErrors().get(0);
                System.debug('### Error ### ' + error.getMessage());
                crUpdate = new CheckResponse();
                crUpdate.success = false;
                crUpdate.objId = recordRetrieved.get(i).Id;
                crUpdate.objName = recordMap.get(recordRetrieved.get(i).Id);
                crUpdate.errorMessage = error.getMessage();
                joUpdate.CheckResponseList.add(crUpdate);
            }
        }

        if(joUpdate.CheckResponseList.size() > 0){
            joUpdate.returnToUrl = pageRef.getUrl();
            errorPageRef.getParameters().put('errorMessageJson', JSON.serialize(joUpdate));
            Database.rollback(sp);
            return errorPageRef;
        }

        */



        return tecOff;

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