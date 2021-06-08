public inherited sharing class HDT_UTL_Morosita {

    public String createCase(Map<String, Object> inputs){

        //Possibili valori di input 
        //Passare in input extraFields e riferimentoContainer e Type
        //Eliminare dalla mappa refContainer e Type
        //Assegnare la restante mappa alla mappa extraFields
        //Probabilmente il type e' gia' all'interno della mappa non serve tirarlo via

        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs> requests = new List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs>();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs request = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs();
        List<String> serializedResponse = new List<String>();

        String refContainer = (String) inputs.remove('refContainer');
        String processType = (String) inputs.remove('type');
        String cluster = 'Morosità';


        Case childCase = new Case();

        //creazione del Case contenitore
        if(refContainer == null){

            Case container = new Case(); //Necessario solo se refContainer nullo

            container.IsContainer__c = true;
            container.Cluster__c = cluster;
            for(String field : inputs.keySet()){

                container.put(field, inputs.get(field));

            }

            HDT_UTL_DatabaseService.insertSobject(container);

            refContainer = (String) container.get('Id');

        }

        childCase.put('Type', processType);
        childCase.put('Cluster__c', cluster);

        for(String field : inputs.keySet()){

            childCase.put(field, inputs.get(field));

        }

        childCase.put('ParentId', refContainer);

        HDT_UTL_DatabaseService.insertSobject(childCase);

        request.contractCode = (String) childCase.get('contractCode'); //Mettere Campo giusto
        request.pod = (String) childCase.get('pod'); //Mettere campo giusto

        requests.add(request);

        serializedResponse = HDT_WS_ArricchimentoDatiTemp.submitRequestFlow(requests);

        //COMPLETARE CON HANDLE DELLA RISPOSTA
        //AGGIORNARE LA FASE IN DA INVIARE TRAMITE FUTURE METHOD

        return null;

    }


}
