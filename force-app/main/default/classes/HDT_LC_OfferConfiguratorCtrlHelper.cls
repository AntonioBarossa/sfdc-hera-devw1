public inherited sharing class HDT_LC_OfferConfiguratorCtrlHelper {
    
    public static List<sObject> getTableDataHelper(String objectApiName, String rate, String searchByField, String searchValue){
        List<sObject> allValues;

        String whereCond = '';

        if(!String.isEmpty(searchByField) && !String.isEmpty(searchValue)){
            whereCond = ' WHERE ' + searchByField + ' LIKE \'%' + searchValue +'%\'';
        }

        String fieldsApiName = '';
        switch on objectApiName {
            when 'FareTypeList__c' {
                fieldsApiName = 'Description__c, Sector__c, PossibleValue__c';
            }
            when 'DiscountListaA__c' {
                fieldsApiName = 'ValidityStartDate__c, Description__c, Sector__c, DiscountType__c, PossibleValue__c, DiscountValue__c';
            }
            when 'DiscountListP__c' {
                fieldsApiName = 'ValidityStartDate__c, Description__c, Sector__c, DiscountType__c, PossibleValue__c, DiscountValue__c';
            }
            when 'PriceListT__c' {
                fieldsApiName = 'ValidityStartDate__c,Description__c,Sector__c,DiscountType__c,PossibleValue__c,PriceValue__c';
            }
            when 'PriceListL__c' {
                fieldsApiName = 'ValidityStartDate__c,Description__c,Sector__c,DiscountType__c,PossibleValue__c,PriceValue__c';
            }
            when 'PriceListQ__c' {
                fieldsApiName = 'ValidityStartDate__c,Description__c,Sector__c,DiscountType__c,PossibleValue__c,PriceValue__c';
            }
            when 'infoGroup' {
                List<Info1GroupList__c> infoOneGroupList;
                infoOneGroupList = HDT_QR_TechnicalOffer.getTariffDetails(infoOneGroupList, rate);
                
                if(infoOneGroupList.size() == 0){
                    return infoOneGroupList;
                }

                List<String> tariffList = new List<String>();
                for(Info1GroupList__c infoGroup : infoOneGroupList){
                    tariffList.add('\'' + infoGroup.DetTariffa__c + '\'');
                }

                if(!String.isEmpty(whereCond)){
                    whereCond += ' AND ';
                } else {
                    whereCond = ' WHERE ';
                }

                whereCond += 'DetRate__c IN ' + tariffList;

                //List<Info2GroupList__c> info2GroupList;
                //info2GroupList = HDT_QR_TechnicalOffer.getInfo2GroupList(info2GroupList, tariffList);
                //return info2GroupList;
                allValues = HDT_QR_TechnicalOffer.getInfo2GroupList(allValues, whereCond);
                return allValues;
            }
        }

        allValues = HDT_QR_TechnicalOffer.getRecordsList(allValues, objectApiName, fieldsApiName, whereCond);
        return allValues;
    }

    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveTechnicalOffer(HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse, String techOffObj, String idToClone, String offerJson, String technicalofferid, String productId, String rate) {
        System.debug('# saveTechnicalOffer controller helper #');
        System.debug('# rate -> ' + rate);

        saveResponse = new HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse();

        Savepoint sp = Database.setSavepoint();

        TechnicalOffer__c tecOff;
        Id tecOffId;
        Boolean isUpsert = !String.isEmpty(technicalofferid);

        if(!isUpsert){

            tecOff = generateTechnicalOfferRecord(tecOff, productId, rate, techOffObj, idToClone);
            //List<Product2> prodList;
            //prodList = HDT_QR_TechnicalOffer.getProductById(prodList, productId);

            //List<RateTemplate__c> rateList;
            //rateList = HDT_QR_TechnicalOffer.getRateByName(rateList, rate);
            //Id rateId = rateList[0].Id;

            //tecOff = new TechnicalOffer__c();
            ////Hera Impronta Zero Casa Sole Luna [Versione] [EVVUD]
            //tecOff.Name = prodList[0].Name + ' [' + prodList[0].Version__c + '] [' + rate + ']';
            //tecOff.Product__c = productId;
            //tecOff.RateCategory__c = rateId;
            
            try{
                SObjectType objtype = Schema.getGlobalDescribe().get('TechnicalOffer__c');
                Schema.DescribeSObjectResult objRes = objtype.getDescribe();
            
                if(objRes.isCreateable()){
                    insert tecOff;
                    tecOffId = tecOff.Id;
                } else {
                    saveResponse.success = false;
                    saveResponse.message = '# ERROR: you don\'t have permission on this obj';
                    saveResponse.dataError = false;
                    return saveResponse;                
                }

            } catch (Exception e){
                saveResponse.success = false;
                saveResponse.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
                saveResponse.errorData = new List<HDT_WRP_TechnicalOffer.HDT_WRP_LineError>();
                HDT_WRP_TechnicalOffer.HDT_WRP_LineError lineError = new HDT_WRP_TechnicalOffer.HDT_WRP_LineError();
                lineError.rowId = '0';
                lineError.errorMessage = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
                saveResponse.errorData.add(lineError);
                saveResponse.dataError = false;
                return saveResponse;
            }
        } else {
            tecOffId = technicalofferid;
        }

        List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow> offerList;
        offerList = (List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>)JSON.deserialize(offerJson, List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>.class);
        System.debug('# offerList size -> ' + offerList.size());

        List<TechnicalOfferItem__c> itemList = new List<TechnicalOfferItem__c>();
        TechnicalOfferItem__c tecOffItem;

        for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow offerLine : offerList){
            tecOffItem = convertWrapperToObject(tecOffItem, offerLine, isUpsert);

            if(!isUpsert){
                tecOffItem.TechnicalOffer__c = tecOffId;
            }

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
            saveResponse.message = 'Offerta salvata correttamente';
            saveResponse.techOffId = tecOffId;
        }
        
        return saveResponse;

    }

    public static TechnicalOffer__c generateTechnicalOfferRecord(TechnicalOffer__c technicalOffer, String productId, String rate, String techOffObj, String idToClone){

        List<Product2> prodList;
        List<RateTemplate__c> rateList;
        technicalOffer = new TechnicalOffer__c();

        if(!String.isEmpty(techOffObj)){
            //In this case we set manual configuration from UI
            technicalOffer = (TechnicalOffer__c)JSON.deserialize(techOffObj, TechnicalOffer__c.class);
            System.debug('# newTechnicalOffer > ' + technicalOffer);
        }

        if(!String.isEmpty(idToClone)){
            //In this case we have to clone TechnicalOffer__c record using recordId
            TechnicalOffer__c recToClone;
            recToClone = HDT_QR_TechnicalOffer.queryTechnicalOfferRecordById(recToClone, idToClone);
            technicalOffer = recToClone.clone(false, true, false, false);
            System.debug('# clonedTechnicalOffer > ' + technicalOffer);
        }

        //Last configuration of the TechnicalOffer__c record
        prodList = HDT_QR_TechnicalOffer.getProductById(prodList, productId);
        rateList = HDT_QR_TechnicalOffer.getRateByName(rateList, rate);

        Id rateId = rateList[0].Id;

        //EXAMPLE --> Hera Impronta Zero Casa Sole Luna [Versione] [EVVUD]
        technicalOffer.Name = prodList[0].ProductCode + ' [' + prodList[0].Version__c + '] [' + rate + ']';
        technicalOffer.NameExternalId__c = technicalOffer.Name;
        technicalOffer.Product__c = productId;
        technicalOffer.RateCategory__c = rateId;

        return technicalOffer;
    }

    public static List<HDT_WRP_TechnicalOffer.HDT_WRP_LineError> databaseInsert(List<TechnicalOfferItem__c> itemList, List<HDT_WRP_TechnicalOffer.HDT_WRP_LineError> errorData){

        SObjectType objtype = Schema.getGlobalDescribe().get('TechnicalOfferItem__c');
 
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isCreateable() && objRes.isUpdateable()){

            List<Database.UpsertResult> insertResults = Database.upsert(itemList, false);

            for(Integer n=0; n<insertResults.size(); n++){
                Database.UpsertResult sr = insertResults[n];

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
        }

        return errorData;
    }

    public static HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow convertObjectToWrapper(TechnicalOfferItem__c tempItem, HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow setSingleRow){
        //setSingleRow.Id = tempItem.RowId__c;
        //setSingleRow.Id = tempItem.Id;
        setSingleRow.rowId = tempItem.Id;
        setSingleRow.definition = tempItem.Definition__c;
        setSingleRow.type = tempItem.Type__c;
        setSingleRow.g = tempItem.G__c;
        setSingleRow.m = tempItem.M__c;
        setSingleRow.v = tempItem.V__c;

        if(String.isEmpty(tempItem.S__c)){
            setSingleRow.s = 'x';
        } else {
            setSingleRow.s = tempItem.S__c;
        }
        
        setSingleRow.rateType.label = tempItem.FareType__c;
        setSingleRow.rateType.value = tempItem.FareTypeValue__c;
        setSingleRow.infoGroup.label = tempItem.InfoGroup__c;
        setSingleRow.infoGroup.value = tempItem.InfoGroupValue__c;
        setSingleRow.numValue.value = tempItem.NumericValue__c;
        setSingleRow.flag.value = (tempItem.Flag__c) ? 'true' : 'false';
        setSingleRow.priceCode.label = tempItem.PriceCode__c;
        setSingleRow.priceCode.value = tempItem.PriceCodeValue__c;
        setSingleRow.discountCode.label = tempItem.DiscountCode__c;
        setSingleRow.discountCode.value = tempItem.DiscountCodeValue__c;

        setSingleRow.stringValue.label = tempItem.StringValue__c;
        return setSingleRow;
    }

    public static TechnicalOfferItem__c convertWrapperToObject(TechnicalOfferItem__c tecOffItem, HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow offerLine, Boolean isUpsert){
        //System.debug('# ' + 
        //'[id = ' + offerLine.id + '] - ' +
        //'[M = ' + offerLine.m + '] - ' +
        //'[V = ' + offerLine.v + '] - ' +
        //'[rateType = ' + offerLine.rateType.value + '] - ' +
        //'[infoGroup = ' + offerLine.infoGroup.value + '] - ' +
        //'[numValue = ' + offerLine.numValue.value + '] - ' +
        //'[flag = ' + offerLine.flag.value + '] - ')
        //'[priceCode = ' + offerLine.priceCode.value + '] - ' +
        //'[stringValue = ' + offerLine.stringValue.value + ']' + 
        //'[tecName = ' + offerLine.tecName + ']'
        //);
        
        tecOffItem = new TechnicalOfferItem__c();

        if(isUpsert){
            tecOffItem.Id = offerLine.rowId;
        }

        tecOffItem.RowId__c = offerLine.id;
        tecOffItem.Type__c = offerLine.type;
        tecOffItem.Definition__c = offerLine.definition;
        tecOffItem.G__c = offerLine.g;
        tecOffItem.V__c = offerLine.v;
        tecOffItem.M__c = offerLine.m;

        if(offerLine.s.equalsIgnoreCase('x')){
            tecOffItem.S__c = null;
        } else {
            tecOffItem.S__c = offerLine.s;
        }

        tecOffItem.Operand__c = offerLine.tecName;
        tecOffItem.FareType__c = offerLine.rateType.label;
        tecOffItem.FareTypeValue__c = offerLine.rateType.value;
        tecOffItem.InfoGroup__c = offerLine.infoGroup.label;
        tecOffItem.InfoGroupValue__c = offerLine.infoGroup.value;
        tecOffItem.NumericValue__c = offerLine.numValue.value;

        if(String.isEmpty(offerLine.flag.value)){
            tecOffItem.Flag__c = false;
        } else if(offerLine.flag.value.equalsIgnoreCase('true')){
            tecOffItem.Flag__c = true;
        } else if(offerLine.flag.value.equalsIgnoreCase('false')){
            tecOffItem.Flag__c = false;
        }

        tecOffItem.PriceCode__c = offerLine.priceCode.label;
        tecOffItem.PriceCodeValue__c = offerLine.infoGroup.value;
        tecOffItem.DiscountCode__c = offerLine.discountCode.label;
        tecOffItem.DiscountCodeValue__c = offerLine.discountCode.value;
        tecOffItem.StringValue__c = offerLine.stringValue.value;
        return tecOffItem;
    }
    
    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse cloneRecordHandler(String recIdToClone, String productId){

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse = new HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse();

        TechnicalOffer__c newTechOff = new TechnicalOffer__c();
        Savepoint sp = Database.setSavepoint();

        List<Product2> prodList;
        prodList = HDT_QR_TechnicalOffer.getProductById(prodList, productId);

        TechnicalOffer__c recToClone;
        recToClone = HDT_QR_TechnicalOffer.queryTechnicalOfferRecordWithChild(recToClone, recIdToClone);

        newTechOff = recToClone.clone(false, true, false, false);
        newTechOff.Name = prodList[0].ProductCode + ' [' + prodList[0].Version__c + '] [' + recToClone.RateCategory__r.Name + ']';
        newTechOff.NameExternalId__c = newTechOff.Name;
        newTechOff.Product__c = productId;

        System.debug('# clone this -> ' + newTechOff);

        try{
            SObjectType objtype = Schema.getGlobalDescribe().get('TechnicalOffer__c');
            Schema.DescribeSObjectResult objRes = objtype.getDescribe();
     
            if(objRes.isCreateable()){
                insert newTechOff;
            } else {
                saveResponse.success = false;
                saveResponse.message = '# ERROR: you don\'t have permission on this obj';
                saveResponse.dataError = false;
                return saveResponse;                
            }

        } catch (Exception e){
            saveResponse.success = false;
            saveResponse.message = '# ERROR: ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
            saveResponse.dataError = false;
            return saveResponse;
        }

        List<TechnicalOfferItem__c> newItemsList = new List<TechnicalOfferItem__c>();
        TechnicalOfferItem__c newItem;
        for(TechnicalOfferItem__c item : recToClone.RigheOffertaTecnica__r){
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

    public static Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>> crateComplexMatrix(){

        StaticResource sr = HDT_QR_TechnicalOffer.getStaticResourceByName('MatrixConfiguration');
        HDT_WRP_TechnicalOffer.HDT_WRP_MatrixData matrixObj = (HDT_WRP_TechnicalOffer.HDT_WRP_MatrixData)JSON.deserialize(sr.Body.toString(), HDT_WRP_TechnicalOffer.HDT_WRP_MatrixData.class);
        
        Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>> operandMap = new Map<String, Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>>();
        Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail> fieldDetailMap;
        for(HDT_WRP_TechnicalOffer.HDT_WRP_MatrixConfig op : matrixObj.data){
            fieldDetailMap = new Map<String, HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail>();
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

    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse deleteTechnicalOfferHelper(List<TechnicalOffer__c> techOffListToDelete, HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse){

        saveResponse = new HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse();
        saveResponse.errorData = new List<HDT_WRP_TechnicalOffer.HDT_WRP_LineError>();
        Savepoint sp = Database.setSavepoint();

        SObjectType objtype = Schema.getGlobalDescribe().get('TechnicalOffer__c');
 
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isDeletable()){

            List<Database.DeleteResult> deleteResults = Database.delete(techOffListToDelete, false);

            for(Integer n=0; n<deleteResults.size(); n++){
                Database.DeleteResult dr = deleteResults[n];

                if (!dr.isSuccess()) {
                    // Operation failed
                    String errorString = '';
                    HDT_WRP_TechnicalOffer.HDT_WRP_LineError lineError = new HDT_WRP_TechnicalOffer.HDT_WRP_LineError();
                    for(Database.Error err : dr.getErrors()) {
                        lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                    }
                    saveResponse.errorData.add(lineError);
                }
            }
        }

        if(saveResponse.errorData.size() > 0){
            Database.rollback(sp);
            saveResponse.success = false;
            saveResponse.message = '# ERROR: delete failed';
        } else {
            saveResponse.success = true;
            saveResponse.message = 'Offerta eliminata correttamente';
        }

        return saveResponse;

    }

    public static HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse sendTechOfferToSap(HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse mulesoftResponse, String technicalOfferId){
        System.debug('>>> sendTechOfferToSAP ');

        mulesoftResponse = new HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse();

        TechnicalOffer__c techOff;
        techOff = HDT_QR_TechnicalOffer.queryTechnicalOfferForWebService(techOff, technicalOfferId);

        if(techOff == null){
            mulesoftResponse.success = false;
            mulesoftResponse.message = 'Nessuna configurazione trovata';
            return mulesoftResponse;
        }

        HDT_WRP_TechnicalOffer.HDT_WRP_TechnicalOfferWebService bodyObj;
        bodyObj = generateHttpBody(bodyObj, techOff);

        if(!bodyObj.success){
            mulesoftResponse.success = false;
            mulesoftResponse.message = 'Errore nella configurazione chiamata SAP';
            return mulesoftResponse;  
        }

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj;
        httpObj = setHttpObject(httpObj);

        String body = JSON.serialize(bodyObj.header);
        System.debug('>>> body obj > ' + body);

        HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl;
        responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);
        //responseCtrl = new HDT_WS_MulesoftCaller.HDT_WRP_Response();
        //responseCtrl.success = true;

        System.debug('>>> responseCtrl > ' + String.valueOf(responseCtrl));

        if(!responseCtrl.success){
            updateProductAfterSap(technicalOfferId, responseCtrl.message, 'ko');
            mulesoftResponse.success = false;
            mulesoftResponse.message = responseCtrl.message;
            return mulesoftResponse;
        }

        updateProductAfterSap(technicalOfferId, 'NewSApcode', 'ok');

        mulesoftResponse.success = true;
        mulesoftResponse.message = 'Offerta inviata a SAP correttamente';
        mulesoftResponse.bodyResponse = '{"newCode": "newValue"}';

        return mulesoftResponse;

    }

    public static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj){

        httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
        httpObj.headersMap = new Map<String, String>();

        //httpObj.endPoint = 'https://monted-dev-ed.my.salesforce.com/services/apexrest/CreateNewOffer';
        //httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
        httpObj.endPoint = 'callout:CpqCommercialOffers';
        httpObj.httpMethod = 'POST';
        httpObj.headersMap.put('Content-Type', 'application/json');

        return httpObj;
    }

    public static HDT_WRP_TechnicalOffer.HDT_WRP_TechnicalOfferWebService generateHttpBody(HDT_WRP_TechnicalOffer.HDT_WRP_TechnicalOfferWebService obj, TechnicalOffer__c techOff){

        obj = new HDT_WRP_TechnicalOffer.HDT_WRP_TechnicalOfferWebService();

        try{
            obj.header = new HDT_WRP_TechnicalOffer.HDT_WRP_Header();
            obj.header.codiceOfferta = techOff.Product__r.ProductCode;
            obj.header.profilo = techOff.Version__c;
            obj.header.categoriaTariffa = techOff.RateCategory__r.Name;
            obj.header.descrizioneOfferta = techOff.Product__r.DescriptionSAP__c;
            obj.header.descrizioneProfilo = techOff.Product__r.DescriptionSAP__c;
            obj.header.mercato = techOff.Market__c;
            obj.header.tipoProcesso = techOff.ProcessType__c;
            obj.header.isOffertaPLACET = convertYesNoFromString(techOff.PlacetOffer__c);
            obj.header.prodotto = techOff.ServiceProduct__c;
            obj.header.idContratto = techOff.ContractId__c;
            obj.header.dataInizioValidita = String.valueOf(techOff.StartDate__c);//aaaa-mm-gg
            obj.header.dataFineValidita = String.valueOf(techOff.EndDate__c);//aaaa-mm-gg
            obj.header.isPassoAmmessoSN = convertYesNoFromString(techOff.StepAllowed__c);
            obj.header.numeroUnitaTempoProroga = techOff.NumberTimeExtension__c;
            obj.header.unitaTempoProroga = techOff.UnitTimeExtension__c;
            obj.header.isDisdettaAmmessa = convertYesNoFromString(techOff.CancellationAllowed__c);
            obj.header.numeroUnitaTempoDisdetta = techOff.NumberDaysMonthsYears__c;
            obj.header.unitaTempoDisdetta = techOff.UnitTerminationTime__c;
            obj.header.isRecessoAmmesso = convertYesNoFromString(techOff.RecessAdmitted__c);
            obj.header.numeroUnitaTempoRecesso = techOff.NumberOfTimeUnits__c;
            obj.header.unitaTempoRecesso = techOff.UnitOfTimeMeasurement__c;
            obj.header.isModificabile = techOff.AdmittingProfileModification__c;
            obj.header.isOffertaDaModificare = techOff.OfferToBeModified__c;

            obj.header.input = new List<HDT_WRP_TechnicalOffer.HDT_WRP_Position>();

            HDT_WRP_TechnicalOffer.HDT_WRP_Position position;
            for(TechnicalOfferItem__c item : techOff.RigheOffertaTecnica__r){
                position = new HDT_WRP_TechnicalOffer.HDT_WRP_Position();

                position.operando = item.Operand__c;
                position.isGestibile = item.G__C;
                position.isModificabile = item.M__C;
                position.statoOperando = item.S__c;
                position.tariffa = item.FareTypeValue__c;
                position.gruppoInformativoTariffa = item.InfoGroupValue__c;
                position.prezzo = item.PriceCodeValue__c;
                position.sconto = item.DiscountCodeValue__c;
                position.valore = item.NumericValue__c;
                position.stringa = item.StringValue__c;

                obj.header.input.add(position);
            }

            obj.success = true;

        } catch(Exception ex){
            System.debug('> ERROR: ' + ex.getMessage() + ', at line [' + String.valueOf(ex.getLineNumber()) + ']');
            obj.success = false;
            obj.message = '> ERROR: ' + ex.getMessage() + ', at line [' + String.valueOf(ex.getLineNumber()) + ']';
        }

        return obj;
    }

    public static Boolean updateProductAfterSap(String technicalOfferId, String bodyResponse, String status){
        List<TechnicalOffer__c> tecOffList;
        tecOffList = HDT_QR_TechnicalOffer.getOfferById(tecOffList, technicalOfferId);

        switch on status {
            when 'draft' {
                tecOffList[0].Status__c = 'Draft';
            }
            when 'ok' {
                tecOffList[0].Status__c = 'Status OK';
                tecOffList[0].SapCode__c = bodyResponse;
            }
            when 'ko' {
                tecOffList[0].Status__c = 'Status KO';
                tecOffList[0].Message__c = bodyResponse;
            }
        }

        SObjectType objtype = Schema.getGlobalDescribe().get('TechnicalOffer__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isUpdateable()){
            update tecOffList;
        }

        return true;

    }

    private static Boolean convertYesNoFromString(String stringField){
        if(!String.isEmpty(stringField)){
            if(stringField.equalsIgnoreCase('Si') || stringField.equalsIgnoreCase('S')){
                return true;
            } else if(stringField.equalsIgnoreCase('No') || stringField.equalsIgnoreCase('N')){
                return false;
            }
        }
        return false;
    }

}