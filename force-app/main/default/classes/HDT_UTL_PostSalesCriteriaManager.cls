public inherited sharing class HDT_UTL_PostSalesCriteriaManager {


    public Boolean distributorManagement(String phaseStory){

        return !(phaseStory.containsIgnoreCase('Pratica non gestita per il DL'));

    }

    public Boolean secondAdmissibility(String phaseStory){

        return !(phaseStory.containsIgnoreCase('Preventivo Accettato'));

    }

    public Boolean notExecWorks(String phaseStory){

        return !(phaseStory.containsIgnoreCase('Dati Tecnici Ricevuti'));

    }

}
