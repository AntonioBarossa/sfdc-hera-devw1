
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity')
public inherited sharing class HDT_UTL_CreatePaymentsRequestBody {

    public String createBodyRequest(List<HDT_UTL_WrapperInput> inputs){
        
        JSONGenerator gen = JSON.createGenerator(true);
        /*
        * @Author: Salvatore A. Sarà 19/10/2021
        * Risoluzione "Local variable is declared and-or assigned but not used"
        */
        // String pretty;

        gen.writeStartObject();

        for(HDT_UTL_WrapperInput input: inputs){

            if(input.isParent){

                for(Map<String, Object> configMap : input.configMapList){

                    writeBody(configMap, gen);

                }
            
            }else if(input.isChild){

                gen.writeFieldName(input.childObjName);
                gen.writeStartArray();
                for(Map<String, Object> configMap : input.configMapList){
                    gen.writeStartObject();
                    writeBody(configMap, gen);
                    gen.writeEndObject();
                }
                gen.writeEndArray();
                
            }

        }

        gen.writeEndObject();

        return gen.getAsString();

    }

    private void writeBody(Map<String, Object> configMap, JSONGenerator gen){

        for(String mapKey : configMap.keySet()){

            if(configMap.get(mapKey) != null){

                if(configMap.get(mapKey) instanceof String){

                    gen.writeStringField(mapKey, (String) configMap.get(mapKey));

                } else if(configMap.get(mapKey) instanceof Integer){

                    gen.writeNumberField(mapKey, (Integer) configMap.get(mapKey));

                }else if(configMap.get(mapKey) instanceof Decimal){

                    gen.writeNumberField(mapKey, (Decimal) configMap.get(mapKey));

                } else if(configMap.get(mapKey) instanceof Date){

                    gen.writeStringField(mapKey, ((Date) configMap.get(mapKey)).format());

                } else if(configMap.get(mapKey) instanceof Boolean){

                    gen.writeBooleanField(mapKey, (Boolean) configMap.get(mapKey));

                }

            }else{

                gen.writeNullField(mapKey);

            }
        }

        return;

    }

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements, PMD.ExcessiveParameterList')
    public void handleResponse(String recordId, String process, String depositMode, HttpResponse response){

        Case caseToUpdate = new Case();
        String phase; 

        caseToUpdate.Id = recordId;

        if(response != null){

            if(process == 'Blocco Sollecito/Interessi')
            {
                HDT_WRP_BloccoSollecito bloccoSollecitoResponse = (HDT_WRP_BloccoSollecito) JSON.deserialize(response.getBody(), HDT_WRP_BloccoSollecito.class);
                if(bloccoSollecitoResponse.response != null && bloccoSollecitoResponse.response.esito.equalsIgnoreCase('KO'))
                {
                    caseToUpdate.TecnicalPhase__c = 'Esito KO da SAP';
                }
                else 
                {
                    caseToUpdate.Phase__c = 'Completata';    
                }
            }   
            else
            {

                HDT_WRP_MinWrapper minWrapper = (HDT_WRP_MinWrapper) JSON.deserialize(response.getBody(), HDT_WRP_MinWrapper.class);

                switch on minWrapper.status{

                    when 'success'{

                        HDT_WRP_SuccessResponse successResponse = 
                            (HDT_WRP_SuccessResponse) JSON.deserialize(response.getBody(), HDT_WRP_SuccessResponse.class);

                        System.debug(LoggingLevel.DEBUG, 'WS_Payments successResponse--> ' + successResponse);

                        phase = handleSuccessResponse(successResponse, recordId, process, depositMode);
                        String note = '';
                        if(successResponse.data != null){
                            if(successResponse.data.numeroBollettino != null){

                                caseToUpdate.PaperlessCode__c = successResponse.data.numeroBollettino;
                            }
                            note = successResponse.data.note;
                        }
                        if(phase != null){

                            caseToUpdate.TecnicalPhase__c = phase;

                        }
                        if (String.isNotBlank(note) && ('Esito KO da SAP'.equalsIgnoreCase(phase)||'Paperless Non Generato'.equalsIgnoreCase(phase))){
                            caseToUpdate.DiscardDescription__c = note;
                        }

                        // if(process == 'Comunicazione Pagamento'
                        // || process == 'Piano Rateizzazione'
                        // || process == 'Paperless'){
                        //     caseToUpdate.Phase__c = 'Inviata a SAP';
                        // }
                        
                    }   
                    when else{ 

                        HDT_WRP_ErrorResponse errorResponse = 
                            (HDT_WRP_ErrorResponse) JSON.deserialize(response.getBody(), HDT_WRP_ErrorResponse.class);

                        System.debug(LoggingLevel.DEBUG, 'WS_Payments errorResponse--> ' + errorResponse);
                        if(process == 'Comunicazione Pagamento'
                        || process == 'Piano Rateizzazione'
                        || process == 'Paperless'
                        || process == 'Blocco Sollecito/Interessi'){
                            caseToUpdate.TecnicalPhase__c = process == 'Paperless'
                            ? 'Paperless Non Generato'
                            : 'Esito KO da SAP';
                        }
                        //createActivity(recordId, errorResponse.errorDetails[0].message, 'Esito KO da SAP');
                        // if(caseToUpdate.Description != null){
                        //     caseToUpdate.Description += '[' + System.Now().format() + ']: ' + errorResponse.errorDetails[0].message +'\n';
                        // }else{
                        //     caseToUpdate.Description  = '[' + System.Now().format() + ']: ' + errorResponse.errorDetails[0].message +'\n';
                        // }
                        try{
                            caseToUpdate.DiscardDescription__c = errorResponse.errorDetails[0].message;
                        }catch (Exception e){
                            caseToUpdate.DiscardDescription__c = 'Unknown error';
                        }
                        
                    }
                }
            }

        } else {
            caseToUpdate.Description = 'Time Out da SAP';
            //caseToUpdate.TecnicalPhase__c = 'Esito KO da SAP';
            //createActivity(recordId, 'Comunicazione con SAP fallita', 'Esito KO da SAP');

        }

        caseToUpdate.NotCancellable__c = true;
        updateFuture(JSON.serialize(caseToUpdate));

    }
    
    
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public String handleSuccessResponse(HDT_WRP_SuccessResponse response, String recordId, String process, String depositMode){

        String phase = null;
        String pianoRateCondition = 'Pratica avviata';
        String comPagCondition = 'Pratica avviata';
        String paperlessCondition = 'OK';

        //Gestione Blocco Sollecito/Interessi
        if(process == 'Blocco Sollecito/Interessi'){
            phase = 'Completata';
            return phase;
        }

        String condition = process == 'Piano Rateizzazione' ? pianoRateCondition : process == 'Comunicazione Pagamento' ? comPagCondition : process == 'Paperless' ? paperlessCondition : null;

        phase = handlePhaseChange(response, recordId, process, condition, depositMode);

        return phase;

    }
    
    
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private String handlePhaseChange(HDT_WRP_SuccessResponse response, String recordId, String process,String condition, String depositMode){
        
        String phase = null;
        String successPhase = (process == 'Piano Rateizzazione' && !depositMode.containsIgnoreCase('Paperless')) //IF
                ? 'Completata' //IF TRUE
                : process == 'Paperless' //ELSE IF
                    ? 'Paperless Generato' //IF TRUE
                    : (process.containsIgnoreCase('Piano Rateizzazione') && depositMode.containsIgnoreCase('Paperless')) || process.containsIgnoreCase('Comunicazione Pagamento') //ELSE IF
                        ? null //IF TRUE
                        : 'Esito OK da SAP'; //ELSE
        String failedPhase = process == 'Paperless'
        ? 'Paperless Non Generato'
        : 'Esito KO da SAP';

        if(condition != null){

            if((response.data.tipoAttivita!= null && response.data.tipoAttivita.containsIgnoreCase(condition))
                || (response.data.esito!= null && response.data.esito.containsIgnoreCase(condition))){

                phase = successPhase;

            } else {

                phase = failedPhase;
                //createActivity(recordId, response.data.note, 'Esito KO da SAP');

            }

        }

        return phase;

    }

    /*private static void createActivity(String recordId, String description, String type){
        String queryString = 'Select id,wrts_prcgvr__Assignees__c, wrts_prcgvr__Subject__c, wrts_prcgvr__DueDateField__c,Name from wrts_prcgvr__ActivityTemplate__c  where Name = \''+ type +'\'';
        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        List<SObject> listRecord = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        wrts_prcgvr__ActivityTemplate__c template = new wrts_prcgvr__ActivityTemplate__c();
        if(description.length() > 255){
            description = description.substring(0, 254);
        }
        if(listRecord.size()>0){
            template = (wrts_prcgvr__ActivityTemplate__c) listRecord[0];
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.wrts_prcgvr__ActivityTemplate__c = template.Id;
            activity.Case__c = recordId;
            activity.CausalError__c = description;
            activity.wrts_prcgvr__Description__c = description;
            Boolean insertAct = HDT_UTL_DatabaseService.insertSObject(activity);
        }
    }*/

    private static void updateFuture(String inputString){

        Case c = (Case) JSON.deserialize(inputString, Case.class);

        HDT_UTL_DatabaseService.updateSObject(c);

    }

    public Date addBusinessDay(Date startDate, Integer businessDayToAdd){

        Date finalDate = startDate;

        Integer direction = businessDayToAdd < 0 ? -1 : 1;

        while(businessDayToAdd != 0){

            finalDate = finalDate.addDays(direction);
            
            if(!isWeekend(finalDate)){

                businessDayToAdd -= direction;
            
            }

        }

        return finalDate;

    }

    public Boolean isWeekend(Date myDate){

        String myDateString = Datetime.newInstance(myDate.year(), myDate.month(),myDate.day()).format('EEE');

        return 'Sat'.equals(myDateString) || 'Sun'.equals(myDateString);

    }


    public class HDT_UTL_WrapperInput{

        public Boolean isParent;
        public Boolean isChild;
        public String childObjName;
        public List<Map<String, Object>> configMapList;

    }

    public class HDT_WRP_MinWrapper{

        public String status;
        public String correlationId;
        public String timestamp;

    }

    public class HDT_WRP_BloccoSollecito
    {
        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_Response response;
    }

    public class HDT_WRP_Response
    {
        public String esito;
    }

    public class HDT_WRP_SuccessResponse{

        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_Data data;

    }

    public class HDT_WRP_Data{

        public String rdsRdo;
        public String tipoAttivita;
        public String note;
        public String numeroBollettino;
        public Decimal importoTotale;
        public String esito;

    }

    public class HDT_WRP_ErrorResponse{

        public String status;
        public String correlationId;
        public String timestamp;
        public List<HDT_WRP_Error> errorDetails;
    }


    public class HDT_WRP_Error{

        public string code;
        public string message;
        public string additionalInfo;

    }


}