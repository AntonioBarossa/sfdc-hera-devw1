public inherited sharing class HDT_LC_AccountStatementCtrlHelper {

    public static HDT_WRP_AccountStatement.HDT_WRP_Tabs getTabsMetaDataHelper(){
        HDT_WRP_AccountStatement.HDT_WRP_Tabs tabsList = new HDT_WRP_AccountStatement.HDT_WRP_Tabs();
        List<HDT_TabConfiguration__mdt> tabMetadataList;
        tabMetadataList = HDT_QR_AccountStatement.getTabMetaData(tabMetadataList);

        if(tabMetadataList.size()==0){
            tabsList.success = false;
            tabsList.message = 'No metadata for tabs';
            return tabsList;
        }

        tabsList.tabDetail = new List<HDT_WRP_AccountStatement.HDT_WRP_TabDetail>();
        HDT_WRP_AccountStatement.HDT_WRP_TabDetail td;
        for(HDT_TabConfiguration__mdt md : tabMetadataList){
            if(md.ShowTab__c){
                td = new HDT_WRP_AccountStatement.HDT_WRP_TabDetail();
                td.label = md.Label;
                td.value = md.DeveloperName;
                tabsList.tabDetail.add(td);
            }
        }

        tabsList.success = true;

        return tabsList;
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj getTabConfigurationHelper(HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj columnsObj, String tabValue, String recordId) {
        System.debug('# GET COLUMNS #');
        System.debug('# Current tab -> ' + tabValue);

        columnsObj = new HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj();

        try{

            List<HDT_ColumnsFirstLevel__mdt> column_mdtList;
            column_mdtList = HDT_QR_AccountStatement.getColumnMetaDataList(column_mdtList, tabValue);

            if(column_mdtList.size()==0){
                columnsObj.success = false;
                columnsObj.message = 'No custom metadata found for coloumns';
                return columnsObj;
            }

            columnsObj.success = true;
            columnsObj.message = '';
            columnsObj.confObj = new HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail();
            columnsObj.columnObj = new List<HDT_WRP_AccountStatement.HDT_WRP_SingleColumn>();

            columnsObj.confObj = getConfObj(tabValue);

            //columnsObj.confObj.recordCode = HDT_QR_AccountStatement.getAccountData(recordId)[0].Name;
            columnsObj.confObj.customerCode = HDT_QR_AccountStatement.getAccountData(recordId)[0].CustomerCode__c;

            if(columnsObj.confObj.buttonList == null || columnsObj.confObj.buttonList.size()==0){
                columnsObj.success = false;
                columnsObj.message = 'Error to retrieve metadata: No data for buttons';
                return columnsObj;
            }

            HDT_WRP_AccountStatement.HDT_WRP_ColumnDetail cd;
            HDT_WRP_AccountStatement.HDT_WRP_SingleColumn sc;
            for(HDT_ColumnsFirstLevel__mdt c : column_mdtList){
                cd = new HDT_WRP_AccountStatement.HDT_WRP_ColumnDetail();
                cd.type = c.FieldType__c;
                cd.isAmount = c.IsAmountField__c;

                sc = new HDT_WRP_AccountStatement.HDT_WRP_SingleColumn();
                sc.label = c.MasterLabel;
                sc.fieldName = c.FieldName__c;
                sc.showSort = c.IsSortable__c;
                sc.isFilter = c.IsFilter__c;
                sc.showAmount = c.ShowTotAmountHere__c;
                sc.detail = cd;
                columnsObj.columnObj.add(sc);
            }

        } catch (Exception ex){
            columnsObj.success = false;
            columnsObj.message = 'Error to retrieve metadata: ' + ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']';
            return columnsObj;
        }

        return columnsObj;
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail getConfObj(String tabValue) {
                
        HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail objDetail = new HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail();
        objDetail.buttonList = new List<HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail>();

        List<HDT_TabConfiguration__mdt> mdtTabConfList;
        mdtTabConfList = HDT_QR_AccountStatement.getTabConfMetadataList(mdtTabConfList, tabValue);
 
        if(mdtTabConfList.size()==0){
            return objDetail;
        }
        
        objDetail.tabCode = tabValue;
        objDetail.secondLevelAPIname = mdtTabConfList[0].SecondLevelAPI_Name__c;
        objDetail.hasSecondLevel = mdtTabConfList[0].HasSecondLevel__c;
        objDetail.hasAmountField = mdtTabConfList[0].HasAmountField__c;
        
        List<HDT_ButtonDetails__mdt> mdtButtonList;
        mdtButtonList = HDT_QR_AccountStatement.getButtonMetadataList(mdtButtonList, tabValue, '1');

        if(mdtButtonList.size()==0){
            return objDetail;
        }

        for(HDT_ButtonDetails__mdt butMdt : mdtButtonList){
            objDetail.buttonList.add(new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail(butMdt.MasterLabel, butMdt.ButtonCode__c, butMdt.IsVisible__c));
        }

        return objDetail;
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj getSecondLevelColumnsHelper(String tabValue) {

        HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj obj = new HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj();

        List<HDT_ColumnsSecondLevel__mdt> colSecList;
        colSecList = HDT_QR_AccountStatement.getColumnsSecondLevel(colSecList, tabValue);

        if(colSecList.size()==0){
            obj.success = false;
            obj.message = 'No data for Second level Columns';
            return obj;
        }

        obj.columnObj = new List<HDT_WRP_AccountStatement.HDT_WRP_SingleSecCol>();

        HDT_WRP_AccountStatement.HDT_WRP_SingleSecCol colObj;
        for(HDT_ColumnsSecondLevel__mdt colSec_mdt : colSecList){
            colObj = new HDT_WRP_AccountStatement.HDT_WRP_SingleSecCol();
            colObj.isFilter = colSec_mdt.IsFilter__c;
            colObj.label = colSec_mdt.MasterLabel;
            colObj.fieldName = colSec_mdt.FieldName__c;
            colObj.sortable = colSec_mdt.Sortable__c;
            colObj.initialWidth = colSec_mdt.InitialWidth__c;
            obj.columnObj.add(colObj);
        }

        List<HDT_ButtonDetails__mdt> mdtButtonList;
        mdtButtonList = HDT_QR_AccountStatement.getButtonMetadataList(mdtButtonList, tabValue, '2');

        if(mdtButtonList.size()==0){
            obj.success = false;
            obj.message = 'No data for Second level button';
            return obj;
        }

        obj.buttonList = new List<HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail>();

        for(HDT_ButtonDetails__mdt button_mdt : mdtButtonList){
            obj.buttonList.add(new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail(button_mdt.MasterLabel, button_mdt.ButtonCode__c, button_mdt.IsVisible__c));
        }

        obj.success = true;

        return obj;
    }

    public static Object createMulesoftCall(String techObj, String requestObj){

        HDT_WRP_AccountStatement.HDT_WRP_ReponseWrapper wrapObj = new HDT_WRP_AccountStatement.HDT_WRP_ReponseWrapper();

        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = (HDT_WRP_AccountStatement.HDT_WRP_TechObj)JSON.deserialize(techObj, HDT_WRP_AccountStatement.HDT_WRP_TechObj.class);
        System.debug('# Technical Object: -> ' + tObj);
        System.debug('# RequestObj -> ' + requestObj);

        /* >>> Technical Object contains
               - requestType
               - statementType
               - recordId
               - tabCode
               - aggregation
               - transactionType
               - customerCode
        */

        /* >>> RequestObj contains (based on tObj.requestType)
               - viewResult -> numeroFattura
               - joinFilter -> aggregazione
                               numeroFattura
                               numeroBollettino
                               contoContrattuale
                               dataInizio
                               dataFine
                               societa
        */

        if(String.isBlank(tObj.customerCode)){
            wrapObj.success = false;
            wrapObj.message = 'No customerCode';
            return wrapObj;     
        }

        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr;
        if(String.isBlank(requestObj)){
            System.debug('# requestObj is null');
            dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        } else {
            System.debug('# requestObj is NOT null');
            dbr = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow)JSON.deserialize(requestObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow.class);
        }

        try{

            /*List<HDT_StatementRequest__mdt> mdtList;
            mdtList = HDT_QR_AccountStatement.getStatementRequestMetaData(mdtList, tObj.requestType);

            if(mdtList.size()==0){
                System.debug('# No custom metadata found on Salesforce');
                wrapObj.success = false;
                wrapObj.message = 'No custom metadata found on Salesforce';
                return wrapObj;
            }*/

            dbr.applicativo = 'ML';//possible value -> ML, MT, AL --> Default=ML only for WAVE1
            dbr.codiceCliente = tObj.customerCode;
            dbr.tipoEstrattoConto = tObj.statementType;
            dbr.loginId = '0-1';
            
            switch on tObj.requestType {
                //Tasto Home
                when 'home' {
                    //applicativo
                    //aggregazione
                    //codiceCliente
                    //tipoTransazione
                    //tipoEstrattoConto
                    //loginId

                    dbr.aggregazione = tObj.aggregation;//01|02|03|04
                    dbr.tipoTransazione = tObj.transactionType;
                }
                //Tasto Tutte le partite recenti:
                when 'allRecentItems' {
                    //dataFine
                    //dataInizio
                    //applicativo
                    //aggregazione
                    //codiceCliente
                    //tipoTransazione
                    //tipoEstrattoConto
                    //loginId

                    dbr.aggregazione = tObj.aggregation;//01|02|03|04
                    dbr.tipoTransazione = 'EC2';
                    Date todayDate = date.today();
                    Date minusDate = todayDate.addYears(-5);                    
                    dbr.dataFine = String.valueOf(todayDate.day()) + '/' + String.valueOf(todayDate.month()) + '/' + String.valueOf(todayDate.year());
                    dbr.dataInizio = String.valueOf(minusDate.day()) + '/' + String.valueOf(minusDate.month()) + '/' + String.valueOf(minusDate.year());
                }
                //Tasto Aggrega&Filtri 
                when 'joinFilter' {
                    //numeroFattura
                    //applicativo
                    //aggregazione
                    //codiceCliente
                    //tipoTransazione
                    //tipoEstrattoConto
                    //loginId

                    dbr.dataFine = convertDateFormat(dbr.dataFine);
                    dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                }
                //Tasto Visualizza Esito
                when 'viewResult' {
                    dbr.aggregazione = tObj.aggregation;//01|02|03|04
                    dbr.tipoTransazione = tObj.transactionType;
                    //numeroFattura - ok
                    //applicativo - ok
                    //aggregazione - ok
                    //codiceCliente - ok
                    //tipoTransazione - ok
                    //tipoEstrattoConto - ok
                    //loginId - ok
                }

            }

        } catch (Exception ex){
            System.debug('# Exception #');
            wrapObj.success = false;
            wrapObj.message = String.valueOf(ex.getLineNumber()) + '; ' + ex.getMessage();
            return wrapObj;
        }

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = setHttpObject(tObj.tabCode);

        if(httpObj == null){
            wrapObj.success = false;
            wrapObj.message = 'Metadati httpObj non configurati';
            return wrapObj;
        }

       String body = JSON.serialize(dbr, true);
       System.debug('>>> body obj > ' + body);

       HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);

       if(!responseCtrl.success){
            wrapObj.success = false;
            wrapObj.message = responseCtrl.message;
            return wrapObj;
        }

        HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj restMessage = (HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj.class);

        if(restMessage.status != 'success'){
            wrapObj.success = false;
            wrapObj.message = 'Mulesoft side [code: ' + restMessage.errorDetails.code;
            wrapObj.message += ']; Detail: ' + restMessage.errorDetails.message;
            wrapObj.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
            return wrapObj;
        }

        wrapObj.success = true;
        wrapObj.data = responseCtrl.body;
        return wrapObj;

    }

    public static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(String tabCode){

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
        httpObj.headersMap = new Map<String, String>();

        List<HDT_TabConfiguration__mdt> endPointMDT;
        endPointMDT = HDT_QR_AccountStatement.getTabConfigurationMetaData(endPointMDT, tabCode);

        if(endPointMDT.size()>0 && !String.isEmpty(endPointMDT[0].EndpointService__c)){

            httpObj.endPoint = endPointMDT[0].EndpointService__c;
            httpObj.headersMap.put('Authorization', 'Basic NDhmZTUxNjVhNDBjNDlhYTliZjRiM2Q5YmNhMjU1MmY6YTc0YjUwZGJhYWMwNDIxNWJmYmY4OWEyZWUzMTVhODA=');

            if(endPointMDT[0].UseMockService__c){
                httpObj.endPoint = 'https://monted-dev-ed.my.salesforce.com/services/apexrest/getAccountStatement/0';
                httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
            }
            httpObj.httpMethod = 'POST';
            httpObj.headersMap.put('Content-Type', 'application/json');
        } else {
            httpObj = null;
        }

        return httpObj;
    }

    public static String convertDateFormat(String inputDate){
        Date tempDate = Date.valueOf(inputDate);
        String day = String.valueOf(tempDate.day());
        String month = String.valueOf(tempDate.month());
        String year = String.valueOf(tempDate.year());
        return day + '/' + month + '/' + year;
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist getFieldValuesHelper(HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist pickObj){
        
        pickObj = new HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist();
        
        try{
            pickObj.companyList = new List<HDT_WRP_AccountStatement.HDT_WRP_PicklistObj>();
            pickObj.joinLevelList = new List<HDT_WRP_AccountStatement.HDT_WRP_PicklistObj>();

            List<HDT_HeraCompany__mdt> companyList;
            companyList = HDT_QR_AccountStatement.getCompanyList(companyList);

            HDT_WRP_AccountStatement.HDT_WRP_PicklistObj company;
            for(HDT_HeraCompany__mdt hc : companyList){
                company  = new HDT_WRP_AccountStatement.HDT_WRP_PicklistObj();
                company.label = hc.Label;
                company.value = hc.DeveloperName;
                pickObj.companyList.add(company);
            }

            Schema.DescribeFieldResult fieldResult = HDT_StatementRequest__mdt.Aggregation__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            HDT_WRP_AccountStatement.HDT_WRP_PicklistObj joinLevel;
            for( Schema.PicklistEntry f : ple){
                joinLevel = new HDT_WRP_AccountStatement.HDT_WRP_PicklistObj();
                joinLevel.label = f.getLabel();
                joinLevel.value = f.getValue();
                pickObj.joinLevelList.add(joinLevel);
            }     

            pickObj.success = true;

        } catch (Exception ex){
            pickObj.success = false;
            pickObj.message = String.valueOf(ex.getLineNumber()) + '; ' + ex.getMessage();
        }

        return pickObj;        
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogBackendHelper(String tabValue, String recordId, String records, HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogResponse, String level){

        serviceCatalogResponse = new HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse();
        
        //List<HDT_ColumnsFirstLevel__mdt> column_mdtList;
        //column_mdtList = HDT_QR_AccountStatement.getColumnMetaDataList(column_mdtList, tabValue);


        try{

            System.debug('> TabValue > ' + tabValue);
            System.debug('> RecordId > ' + recordId);
            System.debug('> Records > ' + records);

            //if(column_mdtList.size()==0){
            //    serviceCatalogResponse.success = false;
            //    serviceCatalogResponse.message = 'NO ColumnsFirstLevel metadata found';
            //    return serviceCatalogResponse;
            //}

            Id currentUserId = UserInfo.getUserId();
            ServiceCatalog__c serviceCatalog = new ServiceCatalog__c();
            serviceCatalog.UserId__c = currentUserId;


            List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj> recordsList;
            recordsList = (List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj>) JSON.deserialize(records, List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj>.class);

            /*
                - Campo Context:
                  Dal primo livello dell’Estratto conto => EC1L;
                  Dal secondo livello => EC2L,
                  Dalla vista Rate => InstallmentsView; --> il pulsante è presente solo nel primo livello
                  Da Note Var Iva => NoteVarIVA; --> il pulsante non esiste
            */

            //set context field
            if(level.equalsIgnoreCase('1')){
                serviceCatalog.Context__c = 'EC1L';
            } else if(level.equalsIgnoreCase('2')){
                serviceCatalog.Context__c = 'EC2L';
                serviceCatalogResponse.success = true;
                serviceCatalogResponse.serviceCatalogId = 'seconLevelId';
                return serviceCatalogResponse;
            }

            if(tabValue.equalsIgnoreCase('EC4')){
                serviceCatalog.Context__c = 'InstallmentsView';
            }
            
            System.debug('>>> recordsList: ' + String.valueOf(recordsList.size()));

            if(recordsList.size() > 1){
 
                Set<String> isInstallmentSet = new Set<String>();
                Set<String> sameCASet = new Set<String>();

                for(HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj obj : recordsList){
                    if(!String.isEmpty(obj.rateizzato)){
                        isInstallmentSet.add(obj.rateizzato);
                    }

                    if(!String.isEmpty(obj.contoContrattuale)){
                        sameCASet.add(obj.contoContrattuale);
                    }
                }

                //- Se tutte le fatture selezionate presentano il campo RATEIZZATO = SI, settare il campo IsInstallment__c = true;
                switch on isInstallmentSet.size() {
                    when 0 {
                        serviceCatalog.IsInstallment__c = false;
                    }

                    when 1 {
                        String f = (new List<String>(isInstallmentSet) )[0];
                        if(f.equalsIgnoreCase('SI')){
                            serviceCatalog.IsInstallment__c = true;
                        }
                    }
                    
                    when 2 {
                        serviceCatalog.IsInstallment__c = false;
                    }                       
                }

                //Se le fatture selezionate hanno tutte lo stesso conto contrattuale, impostare a true il campo SameCA__c; 
                serviceCatalog.SameCA__c = (sameCASet.size() > 1) ? false : true;

            } else {

                serviceCatalog.Multiselect__c = false;

                //- Se il campo Numero fattura del primo livello informativo è diverso da null, settare il campo IsInvoice__c a true; (solo nel caso della selezione di un solo record)
                serviceCatalog.IsInvoice__c = (String.isEmpty(recordsList[0].numeroFattura)) ? false : true;

                //- Se il campo Residuo del record selezionato al primo livello è < 0, settare il campo OnCredit__c a true; (solo nel caso della selezione di un solo record)
                serviceCatalog.OnCredit__c = (Integer.valueOf(recordsList[0].residuo)<0) ? true : false;

                //- Settare il campo Vendor__c con il valore del campo Società del primo livello;
                serviceCatalog.Vendor__c = (String.isEmpty(recordsList[0].societa)) ? '' : recordsList[0].societa;

                //- Se il campo Prescrivibile del 1 livello è uguale a X e il campo DEL_569 è null, settare il campo IsPrescribable__c a true;
                if(!String.isEmpty(recordsList[0].fatturaPrescrivibile) && recordsList[0].fatturaPrescrivibile.equalsIgnoreCase('X') ){
                    serviceCatalog.IsPrescribable__c = true;
                } else {
                    serviceCatalog.IsPrescribable__c = false;
                }

                //- Se tutte le fatture selezionate presentano il campo RATEIZZATO = SI, settare il campo IsInstallment__c = true;
                serviceCatalog.IsInstallment__c = (!String.isEmpty(recordsList[0].rateizzato) && recordsList[0].rateizzato.equalsIgnoreCase('SI')) ? true : false;

                //- Se le fatture selezionate hanno tutte lo stesso conto contrattuale, impostare a true il campo SameCA__c;
                serviceCatalog.SameCA__c = false;
            }

            //- Settare nel campo DocumentSelected__c il JSON delle fatture selezionate (sia 1 che 2 livello)
            serviceCatalog.DocumentSelected__c = records;

            serviceCatalog.UpsertKey__c = currentUserId + '_' + serviceCatalog.Context__c;
            upsert serviceCatalog UpsertKey__c;


            serviceCatalogResponse.success = true;
            serviceCatalogResponse.serviceCatalogId = serviceCatalog.Id;

        } catch(Exception e){
            serviceCatalogResponse.success = false;
            serviceCatalogResponse.message = '> ERROR: ' + e.getMessage() + ' - at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return serviceCatalogResponse;

    }



    public static HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogBackendHelper_TooComplexMethod(String tabValue, String recordId, String records, HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogResponse, String level){

        serviceCatalogResponse = new HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse();
        
        List<HDT_ColumnsFirstLevel__mdt> column_mdtList;
        column_mdtList = HDT_QR_AccountStatement.getColumnMetaDataList(column_mdtList, tabValue);


        try{

            System.debug('> TabValue > ' + tabValue);
            System.debug('> RecordId > ' + recordId);
            System.debug('> Records > ' + records);

            if(column_mdtList.size()==0){
                serviceCatalogResponse.success = false;
                serviceCatalogResponse.message = 'NO ColumnsFirstLevel metadata found';
                return serviceCatalogResponse;
            }

            Id currentUserId = UserInfo.getUserId();
            ServiceCatalog__c serviceCatalog = new ServiceCatalog__c();
            serviceCatalog.UserId__c = currentUserId;

            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped('{"obj":' + records + '}');
            List<Object> recordsList = (List<Object>)jsonMap.get('obj');

            /*
                - Campo Context:
                  Dal primo livello dell’Estratto conto => EC1L;
                  Dal secondo livello => EC2L,
                  Dalla vista Rate => InstallmentsView; --> il pulsante è presente solo nel primo livello
                  Da Note Var Iva => NoteVarIVA; --> il pulsante non esiste
            */

            //set context field
            if(level.equalsIgnoreCase('1')){
                serviceCatalog.Context__c = 'EC1L';
            } else if(level.equalsIgnoreCase('2')){
                serviceCatalog.Context__c = 'EC2L';
            }

            if(tabValue.equalsIgnoreCase('EC4')){
                serviceCatalog.Context__c = 'InstallmentsView';
            }
            
            System.debug('>>> recordsList: ' + String.valueOf(recordsList.size()));

            if(recordsList.size() > 1){
                //- Se selezionate più fatture, impostare a true il campo Multiselect__c; quando vengono selezionati più record del relativo livello
                serviceCatalog.Multiselect__c = true;

                Map<String, Set<String>> chechkMap = new Map<String, Set<String>>();
                Map<String, Object> singleRecordMap;
                for(Object obj : recordsList ){
                    singleRecordMap = (Map<String, Object>)obj;

                    //for(HDT_ColumnsFirstLevel__mdt col_mdt : column_mdtList){
                    //    System.debug('> ' + col_mdt.FieldName__c +' > ' + singleRecordMap.get(col_mdt.FieldName__c));
                    //}
                    if(singleRecordMap.containsKey('contoContrattuale') && !String.isEmpty(String.valueOf(singleRecordMap.get('contoContrattuale')))){
                        String cc = String.valueOf(singleRecordMap.get('contoContrattuale'));
                        if(chechkMap.containsKey('contoContrattuale')){
                            chechkMap.get('contoContrattuale').add(cc);
                        } else {
                            chechkMap.put('contoContrattuale', new Set<String>{cc});
                        }
                    }

                    if(singleRecordMap.containsKey('rateizzato') && !String.isEmpty(String.valueOf(singleRecordMap.get('rateizzato')))){
                        String rtz = String.valueOf(singleRecordMap.get('rateizzato'));
                        if(chechkMap.containsKey('rateizzato')){
                            chechkMap.get('rateizzato').add(rtz);
                        } else {
                            chechkMap.put('rateizzato', new Set<String>{rtz});
                        }
                    }

                    singleRecordMap.clear();
                }

                String s = '';
                //- Se tutte le fatture selezionate presentano il campo RATEIZZATO = SI, settare il campo IsInstallment__c = true;
                if(chechkMap.containsKey('rateizzato')){

                    switch on chechkMap.get('rateizzato').size() {
                        when 0 {
                            serviceCatalog.IsInstallment__c = false;
                        }

                        when 1 {
                            Set<String> str = chechkMap.get('rateizzato');
                            String f = (new List<String>(str) )[0];
                            if(f.equalsIgnoreCase('SI')){
                                serviceCatalog.IsInstallment__c = true;
                            }
                        }
                        
                        when 2 {
                            serviceCatalog.IsInstallment__c = false;
                        }                       
                    }

                    s += 'inst= ' + String.valueOf(chechkMap.get('rateizzato').size());
                }

                if(chechkMap.containsKey('contoContrattuale')){
                    //Se le fatture selezionate hanno tutte lo stesso conto contrattuale, impostare a true il campo SameCA__c; 
                    serviceCatalog.SameCA__c = (chechkMap.get('contoContrattuale').size() > 1) ? false : true;
                    s += ' - ca= ' + String.valueOf(chechkMap.get('contoContrattuale').size());
                }

                serviceCatalog.Vendor__c = s;

            } else {

                serviceCatalog.Multiselect__c = false;

                //- Se il campo Numero fattura del primo livello informativo è diverso da null, settare il campo IsInvoice__c a true; (solo nel caso della selezione di un solo record)
                serviceCatalog.IsInvoice__c = false;

                //- Se il campo Residuo del record selezionato al primo livello è < 0, settare il campo OnCredit__c a true; (solo nel caso della selezione di un solo record)
                serviceCatalog.OnCredit__c = false;

                //- Settare il campo Vendor__c con il valore del campo Società del primo livello;
                serviceCatalog.Vendor__c = '';

                //- Se il campo Prescrivibile del 1 livello è uguale a X e il campo DEL_569 è null, settare il campo IsPrescribable__c a true;
                serviceCatalog.IsPrescribable__c = false;

                //- Se tutte le fatture selezionate presentano il campo RATEIZZATO = SI, settare il campo IsInstallment__c = true;
                serviceCatalog.IsInstallment__c = false;

                //- Se le fatture selezionate hanno tutte lo stesso conto contrattuale, impostare a true il campo SameCA__c;
                serviceCatalog.SameCA__c = false;
            }

            //- Settare nel campo DocumentSelected__c il JSON delle fatture selezionate (sia 1 che 2 livello)
            serviceCatalog.DocumentSelected__c = records;

            serviceCatalog.UpsertKey__c = currentUserId + '_' + serviceCatalog.Context__c;
            upsert serviceCatalog UpsertKey__c;


            serviceCatalogResponse.success = true;
            serviceCatalogResponse.serviceCatalogId = serviceCatalog.Id;

        } catch(Exception e){
            serviceCatalogResponse.success = false;
            serviceCatalogResponse.message = '> ERROR: ' + e.getMessage() + ' - at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return serviceCatalogResponse;

    }

}