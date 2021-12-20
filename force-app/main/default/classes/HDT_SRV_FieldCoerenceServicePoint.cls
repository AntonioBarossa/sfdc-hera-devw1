/*
    @Author:        Edoardo Zanatta
    CreatedDate:    03/12/2021
*/
        
public class HDT_SRV_FieldCoerenceServicePoint {

    public static Boolean checkCoerence(Map<String, String> inputFieldMap){

        Boolean retVal = false;
        String catCliente = inputFieldMap.get('CategoriaCliente');
        String tipoFornitura = inputFieldMap.get('TipoFornitura');
        String tipoImpianto = inputFieldMap.get('TipoImpianto');
        String servizio = inputFieldMap.get('Servizio');
        String profPrelievo = inputFieldMap.get('ProfiloPrelievo');
        String catUso = inputFieldMap.get('CategoriaUso');
        String imposta = inputFieldMap.get('Imposta');
        String fields = 'Id';
        String conditions = 'AccountCategory__c = \'' +catCliente +'\' AND SupplyType__c = \'' +tipoFornitura +'\' AND ImplantType__c = \'' +tipoImpianto +'\' AND Commodity__c = \'' +servizio +'\' AND IsActive__c = true';
        List<FieldCoerenceServicePoint__c> fieldCoerenceList = new List<FieldCoerenceServicePoint__c>();

        conditions += (catCliente.equalsIgnoreCase('Famiglie') || catCliente.equalsIgnoreCase('Grandi Condomini') || catCliente.equalsIgnoreCase('Piccoli Condomini')) ? ' AND WithdrawalClass__c = \'' +profPrelievo +'\' AND UseCategory__c = \'' +catUso +'\'' : '';
        conditions += (!String.isBlank(imposta)) ? ' AND Taxes__c = \'' +imposta +'\'' : '';

        fieldCoerenceList = HDT_QR_GenericQuery.getGenericRecords(fields, 'FieldCoerenceServicePoint__c' , conditions);
        retVal = fieldCoerenceList.size() > 0 ? true : false;
        return retVal;
    }
}