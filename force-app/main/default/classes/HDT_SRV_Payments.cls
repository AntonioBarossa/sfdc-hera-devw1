public inherited sharing class HDT_SRV_Payments {

    HDT_SRV_PaymentCommunication commSrv = new HDT_SRV_PaymentCommunication();
    HDT_SRV_InstallmentPlans plansSrv = new HDT_SRV_InstallmentPlans();
    HDT_SRV_Paperless paperlessSrv = new HDT_SRV_Paperless();
    HDT_SRV_ReminderBlock blockSrv = new HDT_SRV_ReminderBlock();


    public String createRequestBody(String method, String recordId){

        String requestBody;

        switch on method{

            when 'HDT_PaymentCommunication'{

                requestBody = commSrv.createRequestBody(recordId);

            } 

            when 'HDT_InstallmentPlans'{

                requestBody = plansSrv.createRequestBody(recordId);

            }
            when 'HDT_Paperless'{

                requestBody = paperlessSrv.createRequestBody(recordId);

            }

            when 'HDT_ReminderBlock'{

                requestBody = blockSrv.createRequestBody(recordId);

            }

        }

        return requestBody;

    }

}
