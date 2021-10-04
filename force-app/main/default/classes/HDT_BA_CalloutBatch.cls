public with sharing class HDT_BA_CalloutBatch implements Database.Batchable<String>, Database.Stateful,Database.AllowsCallouts{

    public List<String> dtos = new List<String>();
    public String typeCallout = '';
    public String fileZipName = '';

    public Iterable<String> start(Database.BatchableContext context) {
        return this.dtos;
    }


    public void execute(Database.BatchableContext context, List<String> wrapIterable)
    {   
        System.debug('BeforeCallout');
        switch on typeCallout {
            when 'Front Office'{
                HDT_WS_PraxidiaIntegration.callService(wrapIterable[0],'Front Office');
                System.debug('calloutFront');
            }
            when 'Reclami'{
                HDT_WS_PraxidiaIntegration.callService(wrapIterable[0],'Reclami');
                System.debug('calloutReclami');
            }
            when 'Comunicazione Cartacea'{
                HDT_UTL_PaperProcessing.postPaperProcessing(fileZipName, typeCallout, wrapIterable);
                //HDT_WS_PraxidiaIntegration.callService(wrapIterable[0],'Reclami');
                System.debug('calloutReclami');
            }
        }


    }

    public void finish(Database.BatchableContext context) {
        System.debug('FinishMethodNotNecessaryBuRequired');
    }
}
