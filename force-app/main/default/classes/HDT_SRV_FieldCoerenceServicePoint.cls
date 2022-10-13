/*
    @Author:        Edoardo Zanatta
    CreatedDate:    03/12/2021
*/
        
public class HDT_SRV_FieldCoerenceServicePoint {

    public static Boolean checkCoerence(Map<String, Object> inputFieldMap){

        Boolean retVal = false;
        String catCliente = (String) inputFieldMap.get('CategoriaCliente');
        String tipoFornitura = (String) inputFieldMap.get('TipoFornitura');
        String tipoImpianto = (String) inputFieldMap.get('TipoImpianto');
        String servizio = (String) inputFieldMap.get('Servizio');
        String profPrelievo = (String) inputFieldMap.get('ProfiloPrelievo');
        String catUso = (String) inputFieldMap.get('CategoriaUso');
        String imposta = (String) inputFieldMap.get('Imposta');
        Boolean searchTaxes = inputFieldMap.get('searchTaxes') != null ? (Boolean) inputFieldMap.get('searchTaxes') : true; 
        String fields = 'Id';
        String conditions = 'AccountCategory__c = \'' +catCliente +'\' AND SupplyType__c = \'' +tipoFornitura +'\' AND ImplantType__c = \'' +tipoImpianto +'\' AND Commodity__c = \'' +servizio +'\' AND IsActive__c = true';
        List<FieldCoerenceServicePoint__c> fieldCoerenceList = new List<FieldCoerenceServicePoint__c>();

        conditions += (catCliente.equalsIgnoreCase('Famiglie') || catCliente.equalsIgnoreCase('Grandi Condomini') || catCliente.equalsIgnoreCase('Piccoli Condomini')) ? ' AND (WithdrawalClass__c = \'' +profPrelievo +'\' OR WithdrawalClass__c = \'\') AND (UseCategory__c = \'' +catUso +'\' OR UseCategory__c = \'\')' : '';
        if(searchTaxes)
        {
            conditions += (!String.isBlank(imposta)) ? ' AND Taxes__c = \'' +imposta +'\'' : '';
        }   
        fieldCoerenceList = HDT_QR_GenericQuery.getGenericRecords(fields, 'FieldCoerenceServicePoint__c' , conditions);
        retVal = fieldCoerenceList.size() > 0 ? true : false;
        return retVal;
    }

    public static Map<String, Object> checkCoerenceServicePoint(Map<String, Object> servicePoint, Map<String, Object> inputFieldMap)
    {
        String supplyType = (String) servicePoint.get('SupplyType__c');
        String market = (String) servicePoint.get('MarketOrigin__c');
        String commodity = (String) servicePoint.get('CommoditySector__c');
        Map<String, Object> resultMap = new Map<String, Object>
        {
            'valid' => true,
            'message' => ''
        };
        if(String.isNotBlank(supplyType) && (supplyType.equalsIgnoreCase('Domestico') || supplyType.equalsIgnoreCase('A-Domestico')) && String.isNotBlank(market) && market.equalsIgnoreCase('Salvaguardia'))
        {
          resultMap.put('valid', false);
          resultMap.put('message', 'Impossibile selezionare Mercato: \"' + market +'\" per Tipo Fornitura: \"'+ supplyType + '\"');  
        }
        if( String.isNotBlank(commodity) && commodity.equalsIgnoreCase('Acqua') )
        {
            String comune = (String)inputFieldMap.get('SupplyCity__c');
            String companyOwner = (String)inputFieldMap.get('CompanyOwner__c');
            
            List<TownATOTable__c> townAtoTableList = [SELECT Id FROM TownATOTable__c WHERE CompanyOwner__c = :companyOwner AND Town__c = :comune ];

            if( townAtoTableList.isEmpty() )
            {
                resultMap.put('valid', false);
                String errorMessage = 'Societa\' non coerente con il comune selezionato.';
                resultMap.put('message', errorMessage);
            }
        }
        if(String.isNotBlank(commodity) && commodity.equalsIgnoreCase('Gas') && !inputFieldMap.isEmpty() && !(checkCoerence(inputFieldMap)))
        {
            resultMap.put('valid', false);
            String category = (String)inputFieldMap.get('CategoriaCliente');
            String errorMessage = 'Deve esserci coerenza nella compilazione dei seguenti campi: Tipologia Fornitura Cliente, Categoria Cliente, Tipo Impianto';
            errorMessage += category.equalsIgnoreCase('Famiglie') || category.containsIgnoreCase('Condomini') ? 'Classe Profilo Prelievo, Categoria uso.' : '.';
            resultMap.put('message', errorMessage);
        }
        if(String.isNotBlank(commodity) && commodity.equalsIgnoreCase('Energia Elettrica'))
        {
            String powerRequested = (String) servicePoint.get('PowerRequested__c');
            String requestedPhase = (String) servicePoint.get('RequestPhase__c');
            String implantType = (String) servicePoint.get('ImplantType__c');
            String voltageLevel = (String) servicePoint.get('VoltageLevel__c');
            if(String.isNotBlank(powerRequested) && Decimal.valueOf(powerRequested) > 10 && (String.isBlank(requestedPhase) || (String.isNotBlank(requestedPhase) && !requestedPhase.equalsIgnoreCase('Trifase'))))
            {
                resultMap.put('valid', false);
                resultMap.put('message', 'Se la Potenza Richiesta è maggiore di 10, la Fase Richiesta deve essere Trifase');
            }
            if(String.isNotBlank(supplyType) && ((supplyType.equalsIgnoreCase('Domestico') && !implantType.equalsIgnoreCase('13A0-Usi di Abitazione BT')) || (!supplyType.equalsIgnoreCase('Domestico') && implantType.equalsIgnoreCase('13A0-Usi di Abitazione BT'))))
            {
                resultMap.put('valid', false);
                resultMap.put('message','Deve esserci coerenza nella compilazione dei seguenti campi: Tipologia Fornitura Cliente, Tipo Impianto.');
            }
            if(String.isNotBlank(supplyType) && String.isNotBlank(voltageLevel) && supplyType.equalsIgnoreCase('Domestico') && !voltageLevel.equalsIgnoreCase('BT'))
            {
                resultMap.put('valid', false);
                resultMap.put('message','Per Tipo Fornitura: \"' + supplyType + '\" impossibile selezionare Tensione di consegna: \"' + voltageLevel + '\"');
            }
        }
        return resultMap;
    }
}