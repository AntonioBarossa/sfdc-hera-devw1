@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class HDT_WRP_SIE108OrderEnrichment {
    public String orderId;
    public List<HDT_WRP_SIE108Positions> orderEnrichmentList;
    
    public HDT_WRP_SIE108OrderEnrichment() {
        this.orderEnrichmentList = new List<HDT_WRP_SIE108Positions>();
        this.orderId = null;
    }

    public class HDT_WRP_SIE108Positions{
        public String field;
        public String value;
        public HDT_WRP_SIE108Positions(String field, String value){
            this.field = field;
            this.value = value;
        }
    }
}