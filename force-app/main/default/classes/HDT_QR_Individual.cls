/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 18/06/2021
 * @description HDT_QR_Individual.cls - Class that holds queries for Individual
 * @history Sabina Levonja – 18/06/2021 – Creato la classe
 */

public inherited sharing class HDT_QR_Individual {
    
    /**
     * @author Sabina Levonja (sabina.levonja@dunegroup.it)
     * @description Get Individual record by id
     * @param String id
     * @param String fields
     * @return Individual individual
     */ //
    public Individual getRecordById(String id, String fields){

        String query = 'SELECT '+ String.escapeSingleQuotes(fields) +
                ' FROM Individual WHERE Id = :id WITH SECURITY_ENFORCED LIMIT 1';
        List<Individual> individual = Database.query(query);
        Individual indv = new Individual();
        if(!individual.isEmpty()){
            indv= individual[0];

        }
        return indv;
    }
}