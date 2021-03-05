public inherited sharing class HDT_LC_OfferConfiguratorController {

    @AuraEnabled(cacheable=true)
    public static String getTableData(String searchTerm){
        String result = '';
        try{
            if(searchTerm != 'RateTemplate__c'){
                StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DataHelper' WITH SECURITY_ENFORCED LIMIT 1];
                result = sr.Body.toString();
            } else {
                List<RateTemplate__c> rtList = new List<RateTemplate__c>();
                rtList = [
                    SELECT Id, Name
                    FROM RateTemplate__c
                ];
                //result = JSON;
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<RateTemplate__c> getRateList(String queryTerm) {
        return HDT_QR_TechnicalOffer.getRateList(queryTerm);
    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer getExistingOffer(String productId) {
        System.debug('### recordId -> ' + productId);

        HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer respObj = new HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer();
        
        try{
            respObj.success = true;
            respObj.errorMessage = '';
            respObj.data = new HDT_WRP_TechnicalOffer.HDT_WRP_TecnicalOfferObj();

            List<TechnicalOffer__c> tecOffList;
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

        } catch (Exception ex){
            respObj.success = false;
            respObj.errorMessage = ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']';
        }

        return respObj;
    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable getOfferMatrix(String productId, String technicalOfferId, String template){

        //Boolean isMock = false;
        HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable matrixTable = new HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable();

        try{
            matrixTable.rowList = new List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>();

            //HDT_WRP_TechnicalOffer.HDT_WRP_ProductObj prodObj = (HDT_WRP_TechnicalOffer.HDT_WRP_ProductObj)JSON.deserialize(productObj, HDT_WRP_TechnicalOffer.HDT_WRP_ProductObj.class);
            //System.debug('# Product obj -> ' + prodObj);

            //if(isMock){
            //    StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MatrixDataInput' LIMIT 1];
            //    matrixTable.rowList = (List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>)JSON.deserialize(sr.Body.toString(), List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>.class);
            //} else {
                Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>> complexMap = HDT_LC_OfferConfiguratorCtrlHelper.crateComplexMatrix();
    
                //Product2 product = [SELECT Id, Template__c, RateCategory__r.Name FROM Product2 WHERE Id =: productId LIMIT 1];
                
                List<OperandTemplate__c> operands = [
                    SELECT Id, Operands__c, ContractTemplate__c, Typology__c, UnitPrice__c, Definition__c
                    FROM OperandTemplate__c
                    WHERE ContractTemplate__c =: template//product.Template__c
                    WITH SECURITY_ENFORCED
                ];

                HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow singleRow;

                for(Integer n=0; n<operands.size(); n++){    
                    Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail> rowDetailMap = complexMap.get(operands[n].Typology__c);
                    singleRow = new HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow();

                    singleRow.Id = String.valueOf(n);
                    singleRow.definition = operands[n].Definition__c;
                    singleRow.type = operands[n].Typology__c;
                    singleRow.m = false;
                    singleRow.v = true;

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

                    singleRow.stringValue = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
                    singleRow.stringValue.relatedTo = rowDetailMap.get('stringValue').relatedTo;
                    singleRow.stringValue.enabled = rowDetailMap.get('stringValue').enabled;

                    singleRow.tecName = operands[n].Operands__c;
                    matrixTable.rowList.add(singleRow);
                }

                if(!String.isEmpty(technicalOfferId)){
                    TechnicalOffer__c techOff = HDT_LC_OfferConfiguratorCtrlHelper.queryTechnicalOfferRecord(technicalOfferId);
                    Map<String, TechnicalOfferItem__c> itemsMap = new Map<String, TechnicalOfferItem__c>();
                    for(TechnicalOfferItem__c item : techOff.TechnicalOfferItems__r){
                        itemsMap.put(item.RowId__c, item);
                    }

                    TechnicalOfferItem__c tempItem;
                    for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow setSingleRow : matrixTable.rowList){
                        tempItem = itemsMap.get(setSingleRow.id);
                        setSingleRow = HDT_LC_OfferConfiguratorCtrlHelper.convertObjectToWrapper(tempItem, setSingleRow);
                    }    

                }

            //}

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
    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveNewOfferConfigured(String offerJson, String productId, String technicalofferid, String rate){
        System.debug('# saveNewOfferConfigured #');
        System.debug('# technicalofferid> ' + technicalofferid);
        //System.debug(offerJson);

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse();

        try{

            List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow> offerList = (List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>)JSON.deserialize(offerJson, List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>.class);

            if(String.isEmpty(technicalofferid)){
                //Create new record
                saveResponse = HDT_LC_OfferConfiguratorCtrlHelper.saveTechnicalOffer(offerList, productId, rate);
                //HDT_LC_OfferConfiguratorCtrlHelper.updateTechnicalOffer(productId, true);
            } else {
                //update existing record
                saveResponse.success = true;
                saveResponse.techOffId = '';
            }

            if(saveResponse.techOffId != null){
                //send this tech off to SAP
                HDT_LC_OfferConfiguratorCtrlHelper.sendTechOfferToSAP();
            }

            if(!saveResponse.success){
                System.debug('# on controller #');
                for(HDT_WRP_TechnicalOffer.HDT_WRP_LineError le : saveResponse.errorData){
                    System.debug('# ' + le);
                }
            }


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
            recToView = HDT_LC_OfferConfiguratorCtrlHelper.queryTechnicalOfferRecord(recordId);
            
            //StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'offerData' LIMIT 1];
            //result = sr.Body.toString();
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
        return recToView.TechnicalOfferItems__r;
    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse deleteTechnicalOffer(String productId, String technicalOfferId){
        
        System.debug('# deleteOfferMatrix >>> productId: ' + productId + ' - >>> technicalOfferId: ' + technicalOfferId);

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;

        try{

            List<TechnicalOffer__c> techOffList = new List<TechnicalOffer__c>();
            techOffList = [
                SELECT Id
                FROM TechnicalOffer__c
                WHERE Id =: technicalOfferId AND Product__c = :productId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if(techOffList.size()>0){
                saveResponse = HDT_LC_OfferConfiguratorCtrlHelper.deleteTechnicalOfferHelper(techOffList, saveResponse);
                HDT_LC_OfferConfiguratorCtrlHelper.updateTechnicalOffer(productId, false);
            }

        } catch (Exception ex){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + ex.getMessage() + '; at line [' + String.valueOf(ex.getLineNumber()) + ']';
            throw new AuraHandledException(ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']');
        }
        
        return saveResponse;
    }

}