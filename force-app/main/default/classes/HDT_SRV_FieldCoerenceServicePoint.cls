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
        String fields = 'Id';
        String conditions = 'AccountCategory__c = \'' +catCliente +'\' AND SupplyType__c = \'' +tipoFornitura +'\' AND ImplantType__c = \'' +tipoImpianto +'\' AND Commodity__c = \'' +servizio +'\' AND IsActive__c = true';
        List<FieldCoerenceServicePoint__c> fieldCoerenceList = new List<FieldCoerenceServicePoint__c>();

        conditions += (catCliente.equalsIgnoreCase('Famiglie') || catCliente.equalsIgnoreCase('Grandi Condomini') || catCliente.equalsIgnoreCase('Piccoli Condomini')) ? ' AND (WithdrawalClass__c = \'' +profPrelievo +'\' OR WithdrawalClass__c = \'\') AND (UseCategory__c = \'' +catUso +'\' OR UseCategory__c = \'\')' : '';
        conditions += (!String.isBlank(imposta)) ? ' AND Taxes__c = \'' +imposta +'\'' : '';

        fieldCoerenceList = HDT_QR_GenericQuery.getGenericRecords(fields, 'FieldCoerenceServicePoint__c' , conditions);
        retVal = fieldCoerenceList.size() > 0 ? true : false;
        return retVal;
    }
}