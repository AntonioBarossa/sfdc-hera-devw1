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

        System.debug('# HDT_WRP_ColumnsObj > ' + JSON.serialize(columnsObj));
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
        mdtButtonList = HDT_QR_AccountStatement.getButtonMetadataList(mdtButtonList, tabValue);

        if(mdtButtonList.size()==0){
            return objDetail;
        }

        for(HDT_ButtonDetails__mdt butMdt : mdtButtonList){
            objDetail.buttonList.add(new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail(butMdt.MasterLabel, butMdt.ButtonCode__c, butMdt.IsVisible__c));
        }
        System.debug('# ButtonDetails > ' + JSON.serialize(objDetail));
        return objDetail;
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj getSecondLevelColumnsHelper(String tabValue) {

        HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj obj = new HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj();

        List<HDT_ColumnsSecondLevel__mdt> colSecList;
        colSecList = HDT_QR_AccountStatement.getColumnsSecondLevel(colSecList, tabValue);

        if(colSecList.size()==0){
            obj.success = false;
            obj.message = 'No data for Second level';
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

        obj.success = true;
        System.debug('# HDT_WRP_SecLevColumnsObj > ' + JSON.serialize(obj));
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

        /* >>> RequestObj contains
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

            dbr.applicativo = 'AL';//possible value -> ML, MT, AL --> Default=AL only for WAVE1
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
       System.debug('>>> body obj > ');
       System.debug(body);
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
            //httpObj.endPoint = endPointMDT[0].EndpointService__c;
            httpObj.endPoint = 'https://monted-dev-ed.my.salesforce.com/services/apexrest/getAccountStatement/0';
            httpObj.httpMethod = 'POST';
            //httpObj.headersMap.put('Authorization', 'Basic NDhmZTUxNjVhNDBjNDlhYTliZjRiM2Q5YmNhMjU1MmY6YTc0YjUwZGJhYWMwNDIxNWJmYmY4OWEyZWUzMTVhODA=');            
            httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
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

    public static HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogBackendHelper(String tabValue, String recordId, String records, HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogResponse){

        serviceCatalogResponse = new HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse();
       
        try{

            System.debug('> tabValue > ' + tabValue);
            System.debug('> recordId > ' + recordId);
            System.debug('> records > ' + records);

            serviceCatalogResponse.success = true;
            serviceCatalogResponse.serviceCatalogId = 'serviceCatalogId';
        } catch(Exception e){
            serviceCatalogResponse.success = false;
            serviceCatalogResponse.message = '> ERROR: ' + e.getMessage() + ' - at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return serviceCatalogResponse;

    }

}