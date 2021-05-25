public inherited sharing class HDT_UTL_PostSalesCriteriaManager {


    public Boolean distributorManagement(String phaseStory){

        return !(phaseStory.contains('Pratica non gestita per il DL'));

    }

    public Boolean secondAdmissibility(String phaseStory){

        return !(phaseStory.contains('Preventivo Accettato'));

    }

}
