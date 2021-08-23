trigger HDT_TRH_NonReqContractEvent on HDT_PEV_NonReqContract__e (after insert) {

    new HDT_TRH_SelfReadingEvent().run();

}