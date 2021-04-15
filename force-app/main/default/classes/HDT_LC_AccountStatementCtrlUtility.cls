public inherited sharing class HDT_LC_AccountStatementCtrlUtility {

    public static HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow setHttpDataBodyRow(HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr){

        try{

            dbr.codiceCliente = tObj.customerCode;
            dbr.tipoTransazione = tObj.tabCode;
            dbr.applicativo = 'ML';
            dbr.tipoEstrattoConto = tObj.statementType;
            dbr.loginId = '0-1';

            switch on tObj.requestType {
                //Tasto Home
                when 'home' {
                    dbr = setDefaultHttpDataBodyRow(tObj, dbr);
                }
                //Tasto Tutte le partite recenti:
                when 'allRecentItems' {
                    Date todayDate = date.today();
                    Date minusDate = todayDate.addYears(-5);
                    dbr.dataFine = convertDateFormat(String.valueOf(todayDate));
                    dbr.dataInizio = convertDateFormat(String.valueOf(minusDate));
                }
                //Tasto Aggrega&Filtri 
                when 'joinFilter' {
                    dbr.dataFine = convertDateFormat(dbr.dataFine);
                    dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                }
                //Tasto Filtri 
                when 'filters' {
                    dbr.applicativo = 'ML';
                    dbr.aggregazione = null;
                    dbr.codiceCliente = tObj.customerCode;
                    dbr.tipoTransazione = tObj.tabCode;
                    dbr.tipoEstrattoConto = 'ORDINARIO';
                    dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                    dbr.dataFine = convertDateFormat(dbr.dataFine);
                    dbr.numeroFattura = null;
                    dbr.numeroBollettino = dbr.numeroBollettino;
                    dbr.contoContrattuale = null;
                    dbr.societa = null;
                    dbr.contratto = null;
                    dbr.loginId = '0-1';
                }
                //Tasto Visualizza Esito
                when 'viewResult' {
                    dbr.applicativo = null;
                    dbr.codiceCliente = null;
                    dbr.tipoEstrattoConto = null;
                    dbr.loginId = null;
                    dbr.tipoTransazione = 'EC4';
                }

            }

            return dbr;

        } catch(Exception e){
            return null;
        }

    }

    public static HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow setDefaultHttpDataBodyRow(HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr){
        
        switch on tObj.tabCode {
            //Estratto conto
            when 'EC' {
                dbr.aggregazione = '03';
                dbr.tipoTransazione = 'EC1';
            }
            //Gestione del credito
            when 'EC1' {

            }
            //Indennizzi
            when 'EC8' {

            }
            //Note Var. IVA
            when 'NVI' {
                dbr.aggregazione = '03';
            }
            //Pagamenti e compensazioni
            when 'EC5' {

            }
            //Paperless
            when 'paperless' {
                dbr.tipoTransazione = null;
                dbr.tipoEstrattoConto = null;
            }
            //Parite non fatturate
            when 'EC7' {

            }
            //Rate
            when 'EC4' {

            }
            //Scaduto per riattivazione
            when 'EC9' {

            }
            //Solleciti
            when 'EC6' {

            }
        }
        return dbr;
    }

    public static String convertDateFormat(String inputDate){
        Date tempDate = Date.valueOf(inputDate);
        String day = (tempDate.day()<10) ? '0' + String.valueOf(tempDate.day()) : String.valueOf(tempDate.day());
        String month = (tempDate.month()<10) ? '0'+ String.valueOf(tempDate.month()) : String.valueOf(tempDate.month());
        String year = String.valueOf(tempDate.year());
        return day + '/' + month + '/' + year;
    }

    public static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(String tabCode, String requestType){

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
        httpObj.headersMap = new Map<String, String>();

        List<HDT_TabConfiguration__mdt> endPointMDT;
        endPointMDT = HDT_QR_AccountStatement.getTabConfigurationMetaData(endPointMDT, tabCode);

        if(endPointMDT.size()>0 && !String.isEmpty(endPointMDT[0].EndpointService__c) && !String.isEmpty(endPointMDT[0].Authorization__c)){

            httpObj.endPoint = endPointMDT[0].EndpointService__c;
            httpObj.headersMap.put('Authorization', endPointMDT[0].Authorization__c);

            if(endPointMDT[0].UseMockService__c){
                httpObj.endPoint = Label.MockEndPointAccountStatement;
                httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
            }

            httpObj.httpMethod = 'POST';
            httpObj.headersMap.put('Content-Type', 'application/json');

        } else {
            httpObj = null;
        }

        return httpObj;
    }


    public static ServiceCatalog__c executeControllForMultipleRecords(List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj> recordsList, ServiceCatalog__c serviceCatalog){
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
        serviceCatalog.Multiselect__c = true;

        return serviceCatalog;
    }

    public static ServiceCatalog__c executeControllForSingleRecord(HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj record, ServiceCatalog__c serviceCatalog){

        serviceCatalog.Multiselect__c = false;

        //- Se il campo Numero fattura del primo livello informativo è diverso da null, settare il campo IsInvoice__c a true; (solo nel caso della selezione di un solo record)
        serviceCatalog.IsInvoice__c = (String.isEmpty(record.numeroFattura)) ? false : true;

        //- Se il campo Residuo del record selezionato al primo livello è < 0, settare il campo OnCredit__c a true; (solo nel caso della selezione di un solo record)
        serviceCatalog.OnCredit__c = (Integer.valueOf(record.residuo)<0) ? true : false;

        //- Settare il campo Vendor__c con il valore del campo Società del primo livello;
        serviceCatalog.Vendor__c = (String.isEmpty(record.societa)) ? '' : record.societa;

        //- Se il campo Prescrivibile del 1 livello è uguale a X e il campo DEL_569 è null, settare il campo IsPrescribable__c a true;
        if(!String.isEmpty(record.fatturaPrescrivibile) && record.fatturaPrescrivibile.equalsIgnoreCase('X') ){
            serviceCatalog.IsPrescribable__c = true;
        } else {
            serviceCatalog.IsPrescribable__c = false;
        }

        //- Se tutte le fatture selezionate presentano il campo RATEIZZATO = SI, settare il campo IsInstallment__c = true;
        serviceCatalog.IsInstallment__c = (!String.isEmpty(record.rateizzato) && record.rateizzato.equalsIgnoreCase('SI')) ? true : false;

        //- Se le fatture selezionate hanno tutte lo stesso conto contrattuale, impostare a true il campo SameCA__c;
        serviceCatalog.SameCA__c = false;

        return serviceCatalog;

    }

    public static HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse createServiceCatalogRecord_TooComplexMethod(String tabValue, String recordId, String records, HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogResponse, String level){

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