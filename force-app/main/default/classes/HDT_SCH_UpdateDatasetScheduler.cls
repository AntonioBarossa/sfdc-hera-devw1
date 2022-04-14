/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 14/04/2021
 * @description HDT_SCH_UpdateDatasetScheduler - schedula la chiamata al batch di aggiornamento dei dataset,
 *                                               alla chiamata settare tramite costruttore il parametro 
 *                                               per scegliere se aggiornare gli eventLog o i platformLimits
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public with sharing class HDT_SCH_UpdateDatasetScheduler implements Schedulable, Database.Stateful {

    private String choiceJob;   // i valori possibili possono essere 'EventLog' o 'PlatformLimits'

    public HDT_SCH_UpdateDatasetScheduler(String param) {
        this.choiceJob = param; //settaggio del parametro per scegliere quale metodo del batch
    }

    public void execute(SchedulableContext sc) {

            HDT_BA_EventLogToTableau b = new HDT_BA_EventLogToTableau(choiceJob); //inizializzazione batch
            database.executebatch(b); //esecuzione batch

    }
}
