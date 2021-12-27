public with sharing class HDT_UTL_ProcessMorosita extends  HDT_UTL_ProcessExecution {

    public override void checks(){
        System.debug('checks');
        mapFieldsObject();
    }

    public override void getRecords(){
        System.debug('getRecords');
    }

    public override void registryCreation(){
        System.debug('registryCreation');

    }

    public override void finalUpdate(){
        System.debug('finalUpdate');
    }

    private void mapFieldsObject(){

    }

}