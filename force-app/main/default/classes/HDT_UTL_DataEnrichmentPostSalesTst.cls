@IsTest
public with sharing class HDT_UTL_DataEnrichmentPostSalesTst
{

    @TestSetup
    static void makeData(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Famiglie');
        List<BillingProfile__c> billingProfile = HDT_UTL_DataFactoryTst.createBillingProfile(1, false, accList[0].Id);
        billingProfile[0].ContractAccountCode__c = '200013542912';
        insert billingProfile;
    }

    @IsTest
    static void handleResponseTst()
    {
        String response = '{"status":"success","correlationId":"a83ad6a0-fb70-11ec-a588-0257e41969d4","timestamp":"2022-07-04T10:09:42","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"POD","valore":"00882102210891"},{"campo":"DATACESSAZIONE","valore":"99991231"},{"campo":"DATAATTIVAZIONE","valore":"20220501"},{"campo":"FATTURACOLLETTIVA","valore":"2"},{"campo":"VENDITORE","valore":"10V0000160"},{"campo":"ALIQUOTAIVA","valore":"02"},{"campo":"CONTRATTO","valore":"3026175385"},{"campo":"CA","valore":"200013542912"},{"campo":"DEFINIZIONEOFFERTA","valore":"PNNATGCA+N"},{"campo":"DEFINIZIONEPROFILO","valore":"V40"},{"campo":"DESCRFATTURAZCOLL","valore":"Il contratto pu00f2 essere fatturato con altri contratti"},{"campo":"TESTOALIQUOTAIVA","valore":"CLIENTI GENERICI 21%"},{"campo":"IMPIANTO","valore":"4011256256"},{"campo":"TIPOIMPIANTO","valore":"1004"},{"campo":"COMMODITY","valore":"10"},{"campo":"DESCRCOMM","valore":"Gas"},{"campo":"DESCRTIPOIMP","valore":"Riscaldamento promiscuo"},{"campo":"BP","valore":"1009164549"},{"campo":"ACCISE","valore":"0.12000000"},{"campo":"CF","valore":"FRZPLG60C21D810U"},{"campo":"CATEGORIATARIFFA","valore":"GATSMBSCN0"},{"campo":"PERIODOFATTURAZIONE","valore":"2"},{"campo":"DESCRIZIONEPORTION","valore":"Bim fm pari MAU"},{"campo":"DISTRIBUTORE","valore":"10D0000013"},{"campo":"LOCALITA","valore":"MARTINSICURO"},{"campo":"CODIFICALOCALITA","valore":"000000067047"},{"campo":"CODICEPAESE","valore":"IT"},{"campo":"CIVICO","valore":"20"},{"campo":"CAP","valore":"64014"},{"campo":"REGIONE","valore":"TE"},{"campo":"VIA","valore":"VIA FLAVIO GIOIA"},{"campo":"CODICEVIA","valore":"067047000122"},{"campo":"STATODEVICE","valore":"A"},{"campo":"ANNOFABBRCONT","valore":"2000"},{"campo":"CALIBRO1","valore":"GRT003"},{"campo":"MATRICOLA1","valore":"R013OR034420092503"},{"campo":"GRUPPONUMERATORE","valore":"G1V05VOL"},{"campo":"PRESENZACORRETTORE","valore":"NO"},{"campo":"CODICEUFFICIO","valore":"0000000"},{"campo":"MODINVIOFATTURA","valore":"03"},{"campo":"DESCRINVIOFATT","valore":"XML + carta/email"},{"campo":"MERCATO","valore":"LIBERO"},{"campo":"TIPOMERCATO","valore":"17"},{"campo":"CODICEREMI","valore":"34806300"},{"campo":"PRESSIONE","valore":"25.0000000"},{"campo":"CONSUMOCAPDR","valore":"46.0000000"},{"campo":"CONSUMOANNUOGAS","valore":"45.0000000"},{"campo":"IMPOSTE","valore":"G_ICD"},{"campo":"DATAULTIMAGAA","valore":"19930912"},{"campo":"DATAPRIMAGAA","valore":"19890212"},{"campo":"AFPAG_FFUG","valore":"1"}]}}';

        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoResponse responseWrp = (HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoResponse) JSON.deserialize(response, HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoResponse.class);
        Case testCase = new Case();
        List<HDT_UTL_DataEnrichmentPostSales.HDT_UTL_FlowInput> inputs = new List<HDT_UTL_DataEnrichmentPostSales.HDT_UTL_FlowInput>();
        HDT_UTL_DataEnrichmentPostSales.HDT_UTL_FlowInput input = new HDT_UTL_DataEnrichmentPostSales.HDT_UTL_FlowInput();
        input.serializedResponse = JSON.serialize(responseWrp.data.posizioni);
        input.currentCase = testCase;
        inputs.add(input);
        Test.startTest();
            List<Case> testCaseResult = HDT_UTL_DataEnrichmentPostSales.handleResponseFlow(inputs);
        Test.stopTest();
        System.assertEquals(true, testCaseResult[0].Excises__c != null, 'Arricchimento fallito');
        System.assertEquals(true, testCaseResult[0].RegionalAdditional__c != null, 'Arricchimento fallito');
    }
}