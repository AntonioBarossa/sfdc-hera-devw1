public with sharing class HDT_UTL_RimozioneAgevolazione {
    @InvocableMethod(label='HDT_UTL_RimozioneAgevolazione getSalesCompany')
    public static List<HDT_WRP_FlowOutputs> getSalesCompany(List<HDT_WRP_FlowInputs> inputs){
        Map<String, String> agc = HDT_UTL_Sales.getAgentNameAndCode(inputs[0].servicePoint, inputs[0].customerMarking);
        //String brand = HDT_UTL_BrandSalesCompany.getFieldsMatrice(servicePoint.SupplyCity__c,servicePoint.CommoditySector__c,agc.get('nomeAgente'),servicePoint.MarketOrigin__c);
        return new List<HDT_WRP_FlowOutputs>{ new HDT_WRP_FlowOutputs(agc) };
    }

    public class HDT_WRP_FlowInputs{

        @InvocableVariable
        public String customerMarking;
        @InvocableVariable
        public ServicePoint__c servicePoint;

    }

    public class HDT_WRP_FlowOutputs{

        @InvocableVariable
        public String salesCompany;
        @InvocableVariable
        public String salesCompanyCode;


        public HDT_WRP_FlowOutputs(){
            return;
        }

        HDT_WRP_FlowOutputs(Map<String, String> agc){
            this.salesCompany = agc.get('nomeAgente');
            this.salesCompanyCode = agc.get('codiceAgente');
        }

    }
}
