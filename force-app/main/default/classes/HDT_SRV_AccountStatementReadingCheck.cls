@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_AccountStatementReadingCheck {
    
    @InvocableMethod(label='Check Lettura Stimata')
    public static List<HDT_WRP_AccountStatementReadingCheckOutput> execute(List<HDT_WRP_AccountStatementReadingCheckInput> inputs){
        if(inputs==null || inputs.size()<=0) {
            return null;
        }
      
        HDT_WRP_AccountStatementReadingCheckInput input = inputs[0];

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = HDT_LC_AccountStatementCtrlUtility.setHttpObject('EC', '');

        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow bodyWrapper = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        // REQUEST PUNTUALE PER ESTRARRE IL FLAG LETTURA STIMATA LATO SAP
        bodyWrapper.applicativo = 'ML';
        bodyWrapper.aggregazione = '03';
        bodyWrapper.loginId = '0-1';
        bodyWrapper.tipoTransazione = 'EC2';
        bodyWrapper.tipoEstrattoConto = 'ORDINARIO';
        bodyWrapper.codiceCliente = input.customerCode;
        bodyWrapper.contratto = input.contractCode;
        bodyWrapper.numeroFattura = input.numeroFattura;

        String body = JSON.serialize(bodyWrapper, true);
        System.debug(LoggingLevel.DEBUG, 'HDT_SRV_AccountStatementReadingCheck: request body = ' + body);
        HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);

        //System.debug(LoggingLevel.DEBUG, 'HDT_SRV_AccountStatementReadingCheck: response body = ' + responseCtrl.body);

        if (responseCtrl.body == null) {
            return null;
        }

        Boolean isLetturaStimata = false;
        Boolean isMultiContratto = false;
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseCtrl.body);
        //System.debug(LoggingLevel.DEBUG, 'HDT_SRV_AccountStatementReadingCheck: parsed response body = ' + JSON.serialize(responseBodyMap));

        if (responseBodyMap.containsKey('data')) {
            List<Object> dataObj = (List<Object>) responseBodyMap.get('data');
            //System.debug(LoggingLevel.DEBUG, 'HDT_SRV_AccountStatementReadingCheck: parsed response data = ' + dataObj);
            Map<String, Object> primoLivelloMap = (Map<String, Object>) dataObj[0];
            //System.debug(LoggingLevel.DEBUG, 'HDT_SRV_AccountStatementReadingCheck: primo livello = ' + primoLivelloMap);
            List<Object> secondoLivelloList = (List<Object>) primoLivelloMap.get('secondoLivelloInformativo');
            //System.debug(LoggingLevel.DEBUG, 'HDT_SRV_AccountStatementReadingCheck: secondo livello = ' + secondoLivelloList);

            String previousContract = '';
            String currentContract = '';
            for (Object secondoLivello : secondoLivelloList) {
                //System.debug(LoggingLevel.DEBUG, 'record secondo livello: ' + secondoLivello);
                Map<String, Object> secondoLivelloMap = (Map<String, Object>) secondoLivello;
                String letturaStimata = (String) secondoLivelloMap.get('letturaStimata');
                System.debug(LoggingLevel.DEBUG, 'lettura stimata?: ' + letturaStimata);
                if (letturaStimata != null && letturaStimata.equals('X')) {
                    isLetturaStimata = true;
                    break;
                }

                currentContract = (String) secondoLivelloMap.get('contratto');
                if (!String.isBlank(currentContract) && !String.isBlank(previousContract) && !currentContract.equals(previousContract)) {
                    isMultiContratto = true;
                }

                previousContract = currentContract;
            }
        }

        HDT_WRP_AccountStatementReadingCheckOutput output = new HDT_WRP_AccountStatementReadingCheckOutput();
        output.isLetturaStimata = isLetturaStimata;
        output.isMultiContratto = isMultiContratto;

        List<HDT_WRP_AccountStatementReadingCheckOutput> outputList = new List<HDT_WRP_AccountStatementReadingCheckOutput>();
        outputList.add(output);

        return outputList;
    }

    public class HDT_WRP_AccountStatementReadingCheckInput {
    
        @InvocableVariable
        public String customerCode;
        
        @InvocableVariable
        public String contractCode;

        @InvocableVariable
        public String numeroFattura;

    }

    public class HDT_WRP_AccountStatementReadingCheckOutput {
        
        @InvocableVariable
        public Boolean isLetturaStimata; // Se la fattura ha una lettura stimata
        @InvocableVariable
        public Boolean isMultiContratto; // Se la fattura ha contratti diversi al secondo livello.

    }
}
