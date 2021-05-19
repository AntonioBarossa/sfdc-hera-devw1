public inherited sharing class HDT_LC_OfferConfiguratorController {

    @AuraEnabled(cacheable=true)
    public static List<sObject> getTableData(String objectApiName, String rate){
        //String result = '';
        try{
            return HDT_LC_OfferConfiguratorCtrlHelper.getTableDataHelper(objectApiName, rate);

            //if(searchTerm != 'RateTemplate__c'){
            //    StaticResource sr = HDT_QR_TechnicalOffer.getStaticResourceByName('DataHelper');
            //    result = sr.Body.toString();
            //} else {
            //    //List<RateTemplate__c> rtList = new List<RateTemplate__c>();
            //    //rtList = [
            //    //    SELECT Id, Name
            //    //    FROM RateTemplate__c
            //    //];
            //    //result = JSON;
            //}
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        } 

    }

    @AuraEnabled(cacheable=true)
    public static List<RateTemplate__c> getRateList(String queryTerm) {
        return HDT_QR_TechnicalOffer.getRateList(queryTerm);
    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer getExistingOffer(String productId) {
        System.debug('### recordId -> ' + productId);

        HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer respObj = new HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer();
        List<TechnicalOffer__c> tecOffList;
        List<Product2> thisProduct;
        List<Product2> prodList;
        
        try{
            respObj.success = true;
            respObj.errorMessage = '';
            respObj.data = new HDT_WRP_TechnicalOffer.HDT_WRP_TecnicalOfferObj();

            tecOffList = HDT_QR_TechnicalOffer.queryTechnicalOfferByProductId(productId, tecOffList);

            if(tecOffList != null && tecOffList.size() > 0){
                respObj.data.offerIsPresent = true;
                respObj.data.tecnicalOffers = new List<TechnicalOffer__c>();
                respObj.data.tecnicalOffers.addAll(tecOffList);
                //for(TechnicalOffer__c to : tecOffList){
                //    respObj.data.tecnicalOfferId.add(to.Id);
                //}
                
            } else {
                respObj.data.offerIsPresent = false;
                respObj.data.tecnicalOffers = null;            
            }

            thisProduct = HDT_QR_TechnicalOffer.getProductById(thisProduct, productId);
            prodList = HDT_QR_TechnicalOffer.getProduct2ByCode(prodList, thisProduct[0].ProductCode, productId);

            if(prodList.size() > 0 && prodList[0].Technical_Offer__r.size() > 0){
                respObj.data.productCodeIsAlreadyPresent = true;
                respObj.data.techOffIdToClone = prodList[0].Technical_Offer__r[0].Id;
            } else {
                respObj.data.productCodeIsAlreadyPresent = false;
            }

        } catch (Exception ex){
            respObj.success = false;
            respObj.errorMessage = ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']';
        }

        return respObj;
    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable getOfferMatrix(String productId, String technicalOfferId, String template){

        HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable matrixTable = new HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable();

        try{
            matrixTable.rowList = new List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>();

            Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>> complexMap = HDT_LC_OfferConfiguratorCtrlHelper.crateComplexMatrix();
                
            List<OperandTemplate__c> operands;
            operands = HDT_QR_TechnicalOffer.getOperandTemplate(operands, template);

            HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow singleRow;

            for(Integer n=0; n<operands.size(); n++){    
                Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail> rowDetailMap = complexMap.get(operands[n].Typology__c);
                singleRow = new HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow();

                singleRow.Id = String.valueOf(n);
                singleRow.definition = operands[n].Definition__c;
                singleRow.type = operands[n].Typology__c;
                singleRow.g = false;
                singleRow.m = false;
                singleRow.v = true;
                singleRow.s = 'x';

                singleRow.rateType = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
                singleRow.rateType.relatedTo = rowDetailMap.get('rateType').relatedTo;
                singleRow.rateType.enabled = rowDetailMap.get('rateType').enabled;

                singleRow.infoGroup  = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
                singleRow.infoGroup.relatedTo = rowDetailMap.get('infoGroup').relatedTo;
                singleRow.infoGroup.enabled = rowDetailMap.get('infoGroup').enabled;
                
                singleRow.numValue = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
                singleRow.numValue.relatedTo = rowDetailMap.get('numValue').relatedTo;
                singleRow.numValue.enabled = rowDetailMap.get('numValue').enabled;
                
                singleRow.flag = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
                singleRow.flag.relatedTo = rowDetailMap.get('flag').relatedTo;
                singleRow.flag.enabled = rowDetailMap.get('flag').enabled;

                singleRow.priceCode = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
                singleRow.priceCode.relatedTo = rowDetailMap.get('priceCode').relatedTo;
                singleRow.priceCode.enabled = rowDetailMap.get('priceCode').enabled;

                singleRow.discountCode = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
                singleRow.discountCode.relatedTo = rowDetailMap.get('discountCode').relatedTo;
                singleRow.discountCode.enabled = rowDetailMap.get('discountCode').enabled;

                singleRow.stringValue = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
                singleRow.stringValue.relatedTo = rowDetailMap.get('stringValue').relatedTo;
                singleRow.stringValue.enabled = rowDetailMap.get('stringValue').enabled;

                singleRow.tecName = operands[n].Operands__c;
                matrixTable.rowList.add(singleRow);
            }

            if(!String.isEmpty(technicalOfferId)){

                TechnicalOffer__c techOff;
                techOff = HDT_QR_TechnicalOffer.queryTechnicalOfferRecordWithChild(techOff, technicalOfferId);

                Map<String, TechnicalOfferItem__c> itemsMap = new Map<String, TechnicalOfferItem__c>();
                for(TechnicalOfferItem__c item : techOff.RigheOffertaTecnica__r){
                    itemsMap.put(item.RowId__c, item);
                }

                TechnicalOfferItem__c tempItem;
                for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow setSingleRow : matrixTable.rowList){
                    tempItem = itemsMap.get(setSingleRow.id);
                    setSingleRow = HDT_LC_OfferConfiguratorCtrlHelper.convertObjectToWrapper(tempItem, setSingleRow);
                }    

            }

            matrixTable.success = true;
            matrixTable.message = 'Everything is ok';


        } catch (Exception e){
            System.debug('# ERROR -> ' + e.getMessage() + String.valueOf(e.getLineNumber()));
            throw new AuraHandledException('# Error -> ' + e.getMessage() + ', at line [' + String.valueOf(e.getLineNumber()) + ']');
        }

        
        for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow setSingleRow : matrixTable.rowList){
            System.debug('>>> ' + setSingleRow.Id+ ' - ' + setSingleRow.numValue.value);
        }

        return matrixTable;
    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveNewOfferConfigured(String techOffObj, String idToClone, String offerJson, String productId, String technicalofferid, String rate, Boolean sendToSap){
        
        System.debug('# saveNewOfferConfigured #');
        System.debug('# techOffObj > ' + techOffObj);
        System.debug('# idToClone > ' + idToClone);
        System.debug('# technicalofferid > ' + technicalofferid);
        System.debug('# sendToSap > ' + sendToSap);

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;

        try{

            //List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow> offerList;
            //offerList = (List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>)JSON.deserialize(offerJson, List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>.class);
            saveResponse = HDT_LC_OfferConfiguratorCtrlHelper.saveTechnicalOffer(saveResponse, techOffObj, idToClone, offerJson, technicalofferid, productId, rate);

            //if(saveResponse.success && sendToSap && !String.isEmpty(saveResponse.techOffId)){
            //    System.debug('>>> sendToSap');
            //    saveResponse = HDT_LC_OfferConfiguratorCtrlHelper.sendTechOfferToSAP(saveResponse, saveResponse.techOffId);
            //}

        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']');
        }
        
        return saveResponse;

    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse sendTechOfferToSAP(String technicalofferid){
        System.debug('# sendTechOfferToSAP #');
        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;

        try{
            saveResponse = HDT_LC_OfferConfiguratorCtrlHelper.sendTechOfferToSAP(saveResponse, technicalofferid);
        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']');
        }
        
        return saveResponse;

    }

    @AuraEnabled
    public static String cloneRecord(String recIdToClone, String productId){
        
        System.debug('# recIdToClone -> ' + recIdToClone + ' - ' + productId);
        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse();

        try{
            saveResponse = HDT_LC_OfferConfiguratorCtrlHelper.cloneRecordHandler(recIdToClone, productId);
            if(!saveResponse.success){
                System.debug('# on clone controller #');
                for(HDT_WRP_TechnicalOffer.HDT_WRP_LineError le : saveResponse.errorData){
                    System.debug('# ' + le);
                }
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
        return saveResponse.techOffId;
    }

    @AuraEnabled
    public static List<TechnicalOfferItem__c> getTechnicalOfferRecords(String recordId){
        TechnicalOffer__c recToView;
        try{
            recToView = HDT_QR_TechnicalOffer.queryTechnicalOfferRecordWithChild(recToView, recordId);
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
        return recToView.RigheOffertaTecnica__r;
    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse deleteTechnicalOffer(String productId, String technicalOfferId){
        
        System.debug('# deleteOfferMatrix >>> productId: ' + productId + ' - >>> technicalOfferId: ' + technicalOfferId);

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;

        try{

            List<TechnicalOffer__c> techOffList;
            techOffList = HDT_QR_TechnicalOffer.queryTechnicalOffer(techOffList, productId, technicalOfferId);

            if(techOffList.size()>0){
                saveResponse = HDT_LC_OfferConfiguratorCtrlHelper.deleteTechnicalOfferHelper(techOffList, saveResponse);
            }

        } catch (Exception ex){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + ex.getMessage() + '; at line [' + String.valueOf(ex.getLineNumber()) + ']';
            throw new AuraHandledException(ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']');
        }
        
        return saveResponse;
    }

}