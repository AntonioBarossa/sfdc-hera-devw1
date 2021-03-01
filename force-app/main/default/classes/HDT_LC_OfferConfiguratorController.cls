public inherited sharing class HDT_LC_OfferConfiguratorController {

    @AuraEnabled(cacheable=true)
    public static String getTableData(String searchTerm){
        String result = '';
        try{
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DataHelper' WITH SECURITY_ENFORCED LIMIT 1];
            result = sr.Body.toString();

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
        return result;
    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer getExistingOffer(String productId) {
        System.debug('### recordId -> ' + productId);

        HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer respObj = new HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer();
        List<TechnicalOffer__c> tecOffList = new List<TechnicalOffer__c>();

        try{
            respObj.success = true;
            respObj.errorMessage = '';
            respObj.data = new HDT_WRP_TechnicalOffer.HDT_WRP_TecnicalOfferObj();

            tecOffList = [
                SELECT Id
                FROM TechnicalOffer__c
                WHERE Product__c =: productId
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
    public static HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable getOfferMatrix(String productId, String technicalOfferId){

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
    
                Product2 product = [SELECT Id, Template__c, RateCategory__r.Name FROM Product2 WHERE Id =: productId LIMIT 1];
                
                List<OperandTemplate__c> operands = [
                    SELECT Id, Operands__c, ContractTemplate__c, Typology__c, UnitPrice__c, Definition__c
                    FROM OperandTemplate__c
                    WHERE ContractTemplate__c =: product.Template__c
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
                    singleRow.rateType = rowDetailMap.get('rateType');
                    singleRow.infoGroup = rowDetailMap.get('infoGroup');
                    singleRow.numValue = rowDetailMap.get('numValue');
                    singleRow.flag = rowDetailMap.get('flag');
                    singleRow.priceCode = rowDetailMap.get('priceCode');
                    singleRow.stringValue = rowDetailMap.get('stringValue');
                    singleRow.tecName = operands[n].Operands__c;
                    matrixTable.rowList.add(singleRow);
                }

                if(!String.isEmpty(technicalOfferId)){
                    TechnicalOffer__c techOff = HDT_LC_OfferConfiguratorCtrlHelper.queryTechnicalOfferRecord(technicalOfferId);
                    Map<String, TechnicalOfferItem__c> itemsMap = new Map<String, TechnicalOfferItem__c>();
                    for(TechnicalOfferItem__c item : techOff.TechnicalOfferItems__r){
                        itemsMap.put(item.Operand__c, item);
                    }

                    TechnicalOfferItem__c tempItem;
                    for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow setSingleRow : matrixTable.rowList){
                        tempItem = itemsMap.get(setSingleRow.tecName);
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

        
        return matrixTable;
    }

    @AuraEnabled
    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveNewOfferConfigured(String offerJson, String productId){
        System.debug('# saveNewOfferConfigured #');
        //System.debug(offerJson);

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse();

        try{

            List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow> offerList = (List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>)JSON.deserialize(offerJson, List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>.class);

            saveResponse = HDT_LC_OfferConfiguratorCtrlHelper.saveTechnicalOffer(offerList, productId);

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

}