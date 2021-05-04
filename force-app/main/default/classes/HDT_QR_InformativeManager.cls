public with sharing class HDT_QR_InformativeManager {

    //modificare prendendo i cluster dall'oggetto HDT_Informative_Configuration__mdt in base al punto d'innesco.
    public static List<HDT_ClusterProcess__mdt> getClusterProcess(String context)
    {

        context = context == 'ServicePoint__c' || context == 'BillingProfile__c' ? context : context + '__c';

        String query = 'SELECT Id, Cluster__c FROM HDT_Informative_Configuration__mdt WHERE ' +context+ '=true WITH SECURITY_ENFORCED';

        return Database.query(query);

    }
    public static String getProcessByCluster(String cluster){
        return [SELECT Id, Cluster__c,ProcessType__c FROM HDT_ClusterProcess__mdt WHERE Cluster__c =:cluster WITH SECURITY_ENFORCED].ProcessType__c;
    }

    public static List<HDT_Informative_Configuration__mdt> getTopicByCluster(String cluster, String context){

        context = context == 'ServicePoint__c' || context == 'BillingProfile__c' ? context : context + '__c';

        String query = 'SELECT Id, Cluster__c, MacroTopic__c FROM HDT_Informative_Configuration__mdt '+
        'WHERE Cluster__c =:cluster AND ' +context+ '=true WITH SECURITY_ENFORCED';

        return Database.query(query);

    }
    public static List<HDT_Informative_Configuration__mdt> getInfoByTopicCluster(String topic, String cluster, String context){

        context = context == 'ServicePoint__c' || context == 'BillingProfile__c' ? context : context + '__c';

        String query = 'SELECT Id, Cluster__c, MacroTopic__c, InformationDetail__c FROM HDT_Informative_Configuration__mdt '+
        'WHERE Cluster__c =:cluster AND MacroTopic__c =:topic AND ' +context+ '=true WITH SECURITY_ENFORCED';

        return Database.query(query);
    }

    public static Case getFieldToPrePopulate(String recordId){

        return [SELECT InformativeCluster__c, 
        InformativeType__c,
        CommodityFormula__c
        FROM Case
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1];


    }

    public static SObject getPrePopulationInfo(String recordId,String sObjName){

        SObject contextSobj;

        switch on sObjName{

                when 'Case'{

                    contextSobj = [SELECT AccountId, 
                    ServicePoint__c, 
                    Market__c, 
                    BillingProfile__c, 
                    Cluster__c, 
                    Type,
                    SalesCompany__c,
                    Contract__c
                    FROM Case
                    WHERE Id = :recordId
                    WITH SECURITY_ENFORCED
                    LIMIT 1];

                }
                when 'Order'{

                    contextSobj = [SELECT Id,AccountId,
                    ServicePoint__c,
                    Market__c,
                    BillingProfile__c,
                    SalesCompany__c,
                    ContractId,
                    Subprocess__c,
                    Cluster__c
                    FROM Order
                    WHERE Id = :recordId
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                    ];

                }
                when 'Opportunity'{

                    //Sono previsti questi campi sull' opportunity?

                    contextSobj = [SELECT AccountId,
                    //ServicePoint__c,
                    //Market__c,
                    //BillingProfile__c,
                    //SalesCompany__c,
                    ContractId
                    FROM Order
                    WHERE Id =: recordId
                    WITH SECURITY_ENFORCED
                    LIMIT 1]; 


                }
                when 'ServicePoint__c'{

                    contextSobj = [SELECT Account__c,
                    MarketOrigin__c/*,
                    //BillingProfile__c,
                    //Company__c, Non convinto che sia questo il campo corretto
                    Contract__c*/
                    FROM ServicePoint__c
                    WHERE Id =: recordId
                    WITH SECURITY_ENFORCED
                    LIMIT 1];
                

                }
                when 'Contract'{

                    contextSobj = [SELECT Id,
                    BillingProfile__c/*,
                    //BillingProfile__c,
                    //Company__c, Non convinto che sia questo il campo corretto
                    Contract__c*/
                    FROM Contract
                    WHERE ServicePoint__c =: recordId
                    AND Status = 'Active'
                    WITH SECURITY_ENFORCED
                    LIMIT 1];
                }
                when 'BillingProfile__c'{
                    contextSobj = [SELECT Id,
                    Account__c
                    FROM BillingProfile__c
                    WHERE Id =: recordId
                    WITH SECURITY_ENFORCED
                    LIMIT 1]; 
                }
                when 'Lead'{

                    //No query needed

                }
                when 'Contact'{

                    //no query needed

                }
                when 'Account'{

                    //No query needed

                }
        }
       
        return contextSobj;

    }
    
}