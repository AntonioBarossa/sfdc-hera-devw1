public inherited sharing class HDT_UTL_PostSalesManager{


    public void changeCaseValue(Sobject inputCase){

        Case currentCase = (Case) inputCase;

        currentCase.Subject = 'Il metodo ha funzionato';

    }


    public String handleInboundRequest(HDT_WRP_MrrRequest.HDT_WRP_Request request){

        Case currentCase = new Case();
        String recordId;
        String phase;   


        for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){

            if(field.name == 'RECORD_ID'){

                recordId = field.value;
 
            } else if(field.name == 'RECORD_PHASE'){

                phase = field.value;

            }


        }

        currentCase = [SELECT Id, Phase__c, Status FROM CASE WHERE Id = :recordId WITH SECURITY_ENFORCED];


        for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){

            if(field.name == 'FLOW_TYPE'){

                switch on field.value{

                    when 'esito_intermedio'{

                        currentCase.Phase__c = phase;

                    }

                }

            }

        }

        HDT_UTL_DatabaseService.updateSObject(currentCase);

        return null;

    }


}
