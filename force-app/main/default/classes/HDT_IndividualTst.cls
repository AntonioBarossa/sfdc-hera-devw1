
@isTest
public with sharing class HDT_IndividualTst {
    
    @isTest
    public static void HDT_IndividualTst() {

        List<Individual> IndiTest  = HDT_UTL_DataFactoryTst.createIndividual(1,true);


        system.assertNotEquals('', IndiTest[0].id , 'is not Empty');

    }
}
