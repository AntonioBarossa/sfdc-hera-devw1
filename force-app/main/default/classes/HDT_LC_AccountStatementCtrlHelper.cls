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

            List<HDT_ColumnsFirstLevel__mdt> columnMdtList;
            columnMdtList = HDT_QR_AccountStatement.getColumnMetaDataList(columnMdtList, tabValue);

            if(columnMdtList.size()==0){
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
            for(HDT_ColumnsFirstLevel__mdt c : columnMdtList){
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
        objDetail.secondLevelApiName = mdtTabConfList[0].SecondLevelAPI_Name__c;
        objDetail.hasSecondLevel = mdtTabConfList[0].HasSecondLevel__c;
        objDetail.hasAmountField = mdtTabConfList[0].HasAmountField__c;
        
        List<HDT_ButtonDetails__mdt> mdtButtonList;
        mdtButtonList = HDT_QR_AccountStatement.getButtonMetadataList(mdtButtonList, tabValue, '1');

        if(mdtButtonList.size()==0){
            return objDetail;
        }

        for(HDT_ButtonDetails__mdt butMdt : mdtButtonList){
            objDetail.buttonList.add(new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail(butMdt.MasterLabel, butMdt.ButtonCode__c, butMdt.IsVisible__c, butMdt.ButtonType__c, butMdt.Parameters__c));
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
            obj.buttonList.add(new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail(button_mdt.MasterLabel, button_mdt.ButtonCode__c, button_mdt.IsVisible__c, button_mdt.ButtonType__c, ''));
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
        
        dbr = HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);

        if(dbr == null){
            System.debug('# data body row is null #');
            wrapObj.success = false;
            wrapObj.message = '> Error during data body row creation';
            return wrapObj;
        }

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = HDT_LC_AccountStatementCtrlUtility.setHttpObject(tObj.tabCode, tObj.requestType);

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

    public static String getPicklistValueHelper(String tabCode, String fieldName){
        List<HDT_StatementRequest__mdt> mdtList;
        mdtList = HDT_QR_AccountStatement.getStatementRequestMetaData(mdtList, fieldName);
        return mdtList[0].PicklistValues__c;
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist getFieldValuesHelper(HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist pickObj, String tabCode){
        
        pickObj = new HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist();
        
        try{
            pickObj.companyList = new List<HDT_WRP_AccountStatement.HDT_WRP_PicklistObj>();
            pickObj.joinLevelList = new List<HDT_WRP_AccountStatement.HDT_WRP_PicklistObj>();
            List<HDT_StatementRequest__mdt> mdtList;
            List<HDT_HeraCompany__mdt> companyList;
            String deserializeThis = '';

            companyList = HDT_QR_AccountStatement.getCompanyList(companyList);

            HDT_WRP_AccountStatement.HDT_WRP_PicklistObj company;
            for(HDT_HeraCompany__mdt hc : companyList){
                company  = new HDT_WRP_AccountStatement.HDT_WRP_PicklistObj();
                company.label = hc.Label;
                company.value = hc.CompanyCode__c;
                pickObj.companyList.add(company);
            }

            switch on tabCode {
                when 'EC' {
                    deserializeThis = 'AggregazioneTabEc';
                }
    
                when 'EC1' {
                    deserializeThis = 'AggregazioneTabEc1';
                }
                
                when 'EC4' {
                    deserializeThis = 'AggregazioneTabEc4';
                }                       
            }

            mdtList = HDT_QR_AccountStatement.getStatementRequestMetaData(mdtList, deserializeThis);
            pickObj.joinLevelList = (List<HDT_WRP_AccountStatement.HDT_WRP_PicklistObj>)JSON.deserialize(mdtList[0].PicklistValues__c, List<HDT_WRP_AccountStatement.HDT_WRP_PicklistObj>.class);
            pickObj.success = true;

        } catch (Exception ex){
            pickObj.success = false;
            pickObj.message = String.valueOf(ex.getLineNumber()) + '; ' + ex.getMessage();
        }

        return pickObj;        
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogBackendHelper(String tabValue, String recordId, String records, HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogResponse, String level){

        serviceCatalogResponse = new HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse();

        try{

            System.debug('> TabValue > ' + tabValue);
            System.debug('> RecordId > ' + recordId);
            System.debug('> Records > ' + records);
            System.debug('> level > ' + level);

            Id currentUserId = UserInfo.getUserId();
            AccountStatementFilter__c serviceCatalog = new AccountStatementFilter__c();
            serviceCatalog.User__c = currentUserId;

            List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj> recordsList;
            recordsList = (List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj>) JSON.deserialize(records, List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj>.class);

            //set context field
            if(level.equalsIgnoreCase('1')){
                serviceCatalog.Context__c = 'EC1L';
            } else if(level.equalsIgnoreCase('2')){
                serviceCatalog.Context__c = 'EC2L';
            }

            if(tabValue.equalsIgnoreCase('EC4')){
                serviceCatalog.Context__c = 'InstallmentsView';
            }
            
            /*
                1° livello
                    - Single Record:
                            = IsInvoice__c
                            = OnCredit__c
                            = Vendor__c
                            = IsPrescribable__c

                    - Multiple Record:
                            = Multiselect__c
                            = IsInstallment__c
                            = SameCA__c
                            = OnCredit__c

                2° livello
                    - Single Record:
                            = IsRaiFee__c

                    - Multiple Record:
                            = Multiselect__c
                            = IsRaiFee__c
            */

            System.debug('>>> first level size: ' + String.valueOf(recordsList.size()));

            Integer firstLevelSize = recordsList.size();
            Integer secondLevelSize = 0;

            if(serviceCatalog.Context__c.equalsIgnoreCase('EC2L') && recordsList[0].secondoLivelloInformativo != null){
                secondLevelSize = recordsList[0].secondoLivelloInformativo.size();
            }

            //if(recordsList.size() > 1){
            if(firstLevelSize > 1 || secondLevelSize > 1){
                System.debug('>>> Multiple Records');
                serviceCatalog = HDT_LC_AccountStatementCtrlUtility.executeControllForMultipleRecords(recordsList, serviceCatalog);
            } else {
                System.debug('>>> Single Records');
                serviceCatalog = HDT_LC_AccountStatementCtrlUtility.executeControllForSingleRecord(recordsList[0], serviceCatalog);
            }

            serviceCatalog.DocumentSelected__c = records;
            serviceCatalog.Account__c = recordId;
            serviceCatalog.UpsertKey__c = currentUserId + '_' + serviceCatalog.Context__c;

            Boolean upsertResult = HDT_UTL_DatabaseService.upsertSObjectExternalId(new List<SObject>{serviceCatalog}, 'AccountStatementFilter__c', 'UpsertKey__c');

            if(!upsertResult){
                serviceCatalogResponse.success = false;
                serviceCatalogResponse.message = '> ERROR on object permission';
                return serviceCatalogResponse;
            }

            serviceCatalogResponse.success = true;
            serviceCatalogResponse.serviceCatalogId = serviceCatalog.Id;

        } catch(Exception e){
            serviceCatalogResponse.success = false;
            serviceCatalogResponse.message = '> ERROR: ' + e.getMessage() + ' - at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return serviceCatalogResponse;

    }

}