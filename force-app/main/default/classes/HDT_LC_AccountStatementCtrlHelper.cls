@SuppressWarnings('PMD.AvoidDebugStatements')
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
        System.debug(LoggingLevel.DEBUG, '# GET COLUMNS #');
        System.debug(LoggingLevel.DEBUG, '# Current tab -> ' + tabValue);

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

            // CR026 - Montors
            //columnsObj.confObj = getConfObj(tabValue);
            //columnsObj.confObj.recordCode = HDT_QR_AccountStatement.getAccountData(recordId)[0].Name;
            
            Id recId = Id.valueOf(recordId);
            Boolean isExternal = false;
            String sObjName = recId.getSObjectType().getDescribe().getName();

            if(sObjName.equalsIgnoreCase('SiebelCustomer__x') ){
                isExternal = true;
            }

            columnsObj.confObj = getConfObj(tabValue, isExternal);

            if(isExternal){
                columnsObj.confObj.customerCode = HDT_QR_AccountStatement.getSiebelCustomer(recordId)[0].OU_NUM__c;
            } else {
                columnsObj.confObj.customerCode = HDT_QR_AccountStatement.getAccountData(recordId)[0].CustomerCode__c;
            }

            // CR026 - Montors

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
                //montors fix 07/07/2022
                //cd.isAmount = c.IsAmountField__c;
                cd.totAmountStored = 0;
                cd.totAmount = 0;

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

    public static HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail getConfObj(String tabValue, Boolean isExternal) {

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

            if(!isExternal || (isExternal && !butMdt.HideForExtObj__c)){
                objDetail.buttonList.add(new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail(butMdt.MasterLabel, butMdt.ButtonCode__c, butMdt.IsVisible__c, butMdt.ButtonType__c, butMdt.Parameters__c, butMdt.Accesskey__c));
            }
            
        }

        return objDetail;
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj getSecondLevelColumnsHelper(String tabValue, String recordId) {

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
        for(HDT_ColumnsSecondLevel__mdt colSecMdt : colSecList){
            colObj = new HDT_WRP_AccountStatement.HDT_WRP_SingleSecCol();
            colObj.isFilter = colSecMdt.IsFilter__c;
            colObj.label = colSecMdt.MasterLabel;
            colObj.fieldName = colSecMdt.FieldName__c;
            colObj.sortable = colSecMdt.Sortable__c;
            colObj.initialWidth = colSecMdt.InitialWidth__c;
            colObj.type = colSecMdt.FieldType__c;
            colObj.isAmountField = colSecMdt.IsAmountField__c;
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

        Id recId = Id.valueOf(recordId);
        Boolean isExternal = false;
        String sObjName = recId.getSObjectType().getDescribe().getName();

        if(sObjName.equalsIgnoreCase('SiebelCustomer__x') ){
            isExternal = true;
        }

        for(HDT_ButtonDetails__mdt buttonMdt : mdtButtonList){
            if(!isExternal || (isExternal && !buttonMdt.HideForExtObj__c)){
                obj.buttonList.add(new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail(buttonMdt.MasterLabel, buttonMdt.ButtonCode__c, buttonMdt.IsVisible__c, buttonMdt.ButtonType__c, buttonMdt.Parameters__c,buttonMdt.Accesskey__c));
            }
        }

        obj.success = true;

        return obj;
    }

    public static Object createMulesoftCall(String techObj, String requestObj){

        HDT_WRP_AccountStatement.HDT_WRP_ReponseWrapper wrapObj = new HDT_WRP_AccountStatement.HDT_WRP_ReponseWrapper();

        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = (HDT_WRP_AccountStatement.HDT_WRP_TechObj)JSON.deserialize(techObj, HDT_WRP_AccountStatement.HDT_WRP_TechObj.class);
        System.debug(LoggingLevel.DEBUG, '# Technical Object: -> ' + tObj);
        System.debug(LoggingLevel.DEBUG, '# RequestObj -> ' + requestObj);

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
            System.debug(LoggingLevel.DEBUG, '# requestObj is null');
            dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        } else {
            System.debug(LoggingLevel.DEBUG, '# requestObj is NOT null');
            dbr = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow)JSON.deserialize(requestObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow.class);
        }

        dbr = HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);

        if(dbr == null){
            System.debug(LoggingLevel.DEBUG, '# data body row is null #');
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
        System.debug(LoggingLevel.DEBUG, '>>> body obj > ' + body);

        HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);

        if(!responseCtrl.success){
            wrapObj.success = false;
            wrapObj.message = responseCtrl.message;
            return wrapObj;
        }

        HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj restMessage = (HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj.class);

        if(restMessage.status != 'success'){
            wrapObj.success = false;

            wrapObj.message += '[CODE: ' + restMessage.errorDetails[0].code + ']; DETAILS: ';
            for(Integer n=0; n < restMessage.errorDetails.size(); n++){
                wrapObj.message += restMessage.errorDetails[n].message;
                if(n < (restMessage.errorDetails.size()-1)){
                    wrapObj.message += ', ';
                }
            }

            //wrapObj.message = 'Mulesoft side [code: ' + restMessage.errorDetails.code;
            //wrapObj.message += ']; Detail: ' + restMessage.errorDetails.message;
            //wrapObj.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
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

            System.debug(LoggingLevel.DEBUG, '> TabValue > ' + tabValue);
            System.debug(LoggingLevel.DEBUG, '> RecordId > ' + recordId);
            System.debug(LoggingLevel.DEBUG, '> Records > ' + records);
            System.debug(LoggingLevel.DEBUG, '> level > ' + level);

            Id currentUserId = UserInfo.getUserId();
            AccountStatementFilter__c serviceCatalog = new AccountStatementFilter__c();
            serviceCatalog.User__c = currentUserId;

            List<HDT_TabConfiguration__mdt> mdtTabConfList;
            mdtTabConfList = HDT_QR_AccountStatement.getTabConfMetadataList(mdtTabConfList, tabValue);

            List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj> recordsList;
            recordsList = (List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj>) JSON.deserialize(records, List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj>.class);

            /*Map<String, Object> seconLevelMap = (Map<String, Object>)JSON.deserializeUntyped(records);
            List<Object> seconLevelList = (List<Object>)seconLevelMap.get(mdtTabConfList[0].SecondLevelAPI_Name__c);

            System.debug(LoggingLevel.DEBUG, '>>> secondLevelList ' + String.valueOf(seconLevelList));*/

            //set context field
            if(level.equalsIgnoreCase('1')){
                serviceCatalog.Context__c = 'EC1L';
            } else if(level.equalsIgnoreCase('2')){
                serviceCatalog.Context__c = 'EC2L';
            }

            if(tabValue.equalsIgnoreCase('EC4')){
                serviceCatalog.Context__c = 'InstallmentsView';
            }
            
            if(tabValue.equalsIgnoreCase('EC7')){
                serviceCatalog.Context__c = 'EC7';
            }
            if(tabValue.equalsIgnoreCase('paperless')){
                serviceCatalog.Context__c = 'Paperless';
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

            System.debug(LoggingLevel.DEBUG, '>>> first level size: ' + String.valueOf(recordsList.size()));

            Integer firstLevelSize = recordsList.size();
            Integer secondLevelSize = 0;

            if(serviceCatalog.Context__c.equalsIgnoreCase('EC2L') && recordsList[0].secondoLivelloInformativo != null){
                secondLevelSize = recordsList[0].secondoLivelloInformativo.size();
            }

            /**@frapnico 22/10/2021
             * Changed order of execution to let the Account__c field be passed 
             * inside the Multiple/Single record checks
             */
            serviceCatalog.DocumentSelected__c = records;
            serviceCatalog.Account__c = recordId;
            serviceCatalog.UpsertKey__c = currentUserId + '_' + serviceCatalog.Context__c;
            
            //if(recordsList.size() > 1){
            if(firstLevelSize > 1 || secondLevelSize > 1){
                System.debug(LoggingLevel.DEBUG, '>>> Multiple Records');
                serviceCatalog = HDT_LC_AccountStatementCtrlUtility.executeControllForMultipleRecords(recordsList, serviceCatalog, tabValue);
            } else {
                System.debug(LoggingLevel.DEBUG, '>>> Single Records');
                serviceCatalog = HDT_LC_AccountStatementCtrlUtility.executeControllForSingleRecord(recordsList[0], serviceCatalog, tabValue);
            }           

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

    public static String buildDefaultRequest(String activityId){
        System.debug('>>> activityId: ' + activityId);

        List<wrts_prcgvr__Activity__c> activity = HDT_QR_AccountStatement.getActivityById(activityId);
        JSONGenerator gen = JSON.createGenerator(true);

        //System.debug('> SapContractCode__c ' + activity[0].Order__r.Contract.SapContractCode__c);
        System.debug('> CommodityFormula__c ' + activity[0].Order__r.CommodityFormula__c);

        if(activity.size() > 0
           //&& String.isNotEmpty(activity[0].Order__r.Contract.SapContractCode__c)
           && String.isNotEmpty(activity[0].Order__r.CommodityFormula__c)
           ){
            Map<String, String> serviceValueMap = new Map<String, String>();
            try{
                String commodity = getPicklistValueHelper('', 'ServiceValues');
          
                List<Object> serviceValueList = (List<Object>)JSON.deserializeUntyped(commodity);
                Map<String, Object> temp;
                for(Integer n=0; n<serviceValueList.size(); n++){
                    temp = (Map<String, Object>)serviceValueList[n];
                    serviceValueMap.put(String.valueOf(temp.get('label')), String.valueOf(temp.get('value')));
                }

                System.debug('>>>' +  serviceValueMap);
            } catch (Exception e){
                return '';
            }

            gen.writeStartObject();
            gen.writeStringField('originLwc', 'activity');
            gen.writeStringField('servizio', serviceValueMap.get(activity[0].Order__r.CommodityFormula__c));
            //gen.writeStringField('contratto', String.valueOf(activity[0].Order__r.Contract.SapContractCode__c));
            gen.writeEndObject();
    
            System.debug('>>> defaultRequest: ' + gen.getAsString());

        } else {
            return '';
        }

        return gen.getAsString();
    }

}