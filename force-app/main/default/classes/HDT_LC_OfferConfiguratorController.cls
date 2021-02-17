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
    public static HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable getOfferMatrix(String productId){

        Boolean isMock = false;
        HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable matrixTable = new HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable();

        try{
            matrixTable.rowList = new List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>();

            //HDT_WRP_TechnicalOffer.HDT_WRP_ProductObj prodObj = (HDT_WRP_TechnicalOffer.HDT_WRP_ProductObj)JSON.deserialize(productObj, HDT_WRP_TechnicalOffer.HDT_WRP_ProductObj.class);
            //System.debug('# Product obj -> ' + prodObj);

            if(isMock){
                StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MatrixDataInput' LIMIT 1];
                matrixTable.rowList = (List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>)JSON.deserialize(sr.Body.toString(), List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>.class);
            } else {
                Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>> complexMap = HDT_LC_OfferConfiguratorCtrlHelper.crateComplexMatrix();
    
                Product2 product = [SELECT Id, Template__c, RateCategory__r.Name FROM Product2 WHERE Id =: productId LIMIT 1];
                
                List<OperandTemplate__c> operands = [
                    SELECT Id, Operands__c, ContractTemplate__c, Typology__c, UnitPrice__c, Definition__c
                    FROM OperandTemplate__c
                    WHERE ContractTemplate__c =: product.Template__c
                ];

                HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow singleRow;
                //for(OperandTemplate__c singleOperand : operands){
                for(Integer n=0; n<operands.size(); n++){    
                    Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail> rowDetailMap = complexMap.get(operands[n].Typology__c);
                    singleRow = new HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow();

                    singleRow.Id = String.valueOf(n);
                    singleRow.definition = operands[n].Definition__c;
                    singleRow.type = operands[n].Typology__c;
                    singleRow.m = false;
                    singleRow.v = true;
                    //singleRow.startDate = rowDetailMap.get('startDate');
                    //singleRow.endDate = rowDetailMap.get('endDate');
                    singleRow.rateType = rowDetailMap.get('rateType');
                    singleRow.infoGroup = rowDetailMap.get('infoGroup');
                    singleRow.numValue = rowDetailMap.get('numValue');
                    singleRow.flag = rowDetailMap.get('flag');
                    singleRow.priceCode = rowDetailMap.get('priceCode');
                    singleRow.stringValue = rowDetailMap.get('stringValue');
                    singleRow.tecName = operands[n].Operands__c;
                    matrixTable.rowList.add(singleRow);
                }

                if(false){
                    TechnicalOffer__c techOff = HDT_LC_OfferConfiguratorCtrlHelper.queryTechnicalOfferRecord('a2z1x000000DbrAAAS');
                    Map<String, TechnicalOfferItem__c> itemsMap = new Map<String, TechnicalOfferItem__c>();
                    for(TechnicalOfferItem__c item : techOff.TechnicalOfferItems__r){
                        itemsMap.put(item.Operand__c, item);
                    }

                    for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow item : matrixTable.rowList){
                        TechnicalOfferItem__c tempItem = itemsMap.get(item.tecName);
                        
                        singleRow.Id = tempItem.RowId__c;
                        singleRow.definition = tempItem.Definition__c;
                        singleRow.type = tempItem.Type__c;
                        singleRow.m = tempItem.M__c;
                        singleRow.v = tempItem.V__c;
                        singleRow.rateType.value = tempItem.FareType__c;
                        singleRow.infoGroup.value = tempItem.InfoGroup__c;
                        singleRow.numValue.value = tempItem.NumericValue__c;
                        //singleRow.flag.value = (String)tempItem.get('Flag__c');
                        singleRow.priceCode.value = tempItem.PriceCode__c;
                        singleRow.stringValue.value = tempItem.StringValue__c;
                    }                    
                }


            }

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