@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class HDT_WRP_SolContractVas {
    
    public List<HDT_WRP_Vas> listOfVas;
    
    public HDT_WRP_SolContractVas(){
        this.listOfVas = new List<HDT_WRP_Vas>();
    }

    public class HDT_WRP_Vas{
        public String herNameVersioneVas;
        public String idVas;
        public String assetNumber;
        public String herCanone;
        public String herCodOfferta;
        public String herDurataVas;
        public String herNomeVas;
        public String herProfile;
        public String herVersioneVas;
        public String herVincoloVas;
        public String ownerAccountId;
    }
}
