global inherited sharing class HDT_SRV_PostSalesManager implements wrts_prcgvr.Interfaces_1_0.IApexAction{

    private HDT_UTL_PostSalesManager psmUtl = new HDT_UTL_PostSalesManager();

    global Object execute(Object args){

        Map<String, Object> argsMap = (Map<String, Object>) args;

        SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        switch on method{

            when 'changeCaseValue'{

                psmUtl.changeCaseValue(sender);

            }

            when 'changeQuotationType'{

                psmUtl.changeQuotationType(sender);

            }

            when 'closeContract'{

                psmUtl.closeContract(sender);

            }

            when 'handleVariazioneAnagraficaCliente'{

                psmUtl.handleVariazioneAnagraficaCliente(sender);

            }
        }

        return null;


    }


}