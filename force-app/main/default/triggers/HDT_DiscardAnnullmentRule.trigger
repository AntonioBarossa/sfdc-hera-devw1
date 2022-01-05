trigger HDT_DiscardAnnullmentRule on DiscardAnnullmentRule__c (before insert, before update) {

    new HDT_TRH_DiscardAnnullmentRule().run();

}