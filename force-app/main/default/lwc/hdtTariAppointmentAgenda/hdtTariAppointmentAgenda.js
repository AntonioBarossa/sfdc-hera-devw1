import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleSearch from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleSearch';
import handleView from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleView';
import handleConfirm from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleConfirm';
import handleWithdrawalCreation from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleWithdrawalCreation';
import getCase from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.getCase';
import handleNewActivityCreationAndCaseUpdate from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleNewActivityCreationAndCaseUpdate';


const OBJECT_FIELDS =[
    'CaseNumber',
    'Outcome__c',
    // 'AppointmentCode__c',
    // 'JobCenterCode__c',
    // 'SotCode__c',
    'StartAppointment__c',
    'EndAppointment__c',
    'WithdrawalFee__c',
    'ServicePoint__c',
    'CreatedDate'
];

// const COLUMNS = [
//     { label: 'Data appuntamento', fieldName: 'data', type: 'text' },
//     { label: 'Fascia oraria', fieldName: 'fascia', type: 'text' },
//     { label: 'Stima durata', fieldName: 'stima', type: 'text' },
//     { label: 'Codice Appuntamento', fieldName: 'codice', type: 'text' },
//     { label: 'Data limite modifica', fieldName: 'dataLimite', type: 'text' },
//     { label: 'Ora limite validità', fieldName: 'oraLimite', type: 'text' }
// ];

const COLUMNS = [
    { label: 'outcome', fieldName: 'outcome', type: 'text' },//TODO
    { label: 'text', fieldName: 'text', type: 'text' },
    { label: 'Data Inizio Appuntamento', fieldName: 'startDate', type: 'text' },
    { label: 'Data Fine Appuntamento', fieldName: 'endDate', type: 'text' },
];

const COLUMNSVIEW = [
    { label: 'noticeNumber', fieldName: 'noticeNumber', type: 'text' },//TODO
    { label: 'appointmentType', fieldName: 'appointmentType', type: 'text' },
    { label: 'Data Inizio Appuntamento', fieldName: 'startDate', type: 'text' },
    { label: 'Data Fine Appuntamento', fieldName: 'endDate', type: 'text' },
];

class Objectfields{
    constructor(startAppointment,endAppointment,phase,note,outcome){
        // this.appointmentCode = appointmentCode;
        // this.jobCenterCode = jobCenterCode;
        // this.sotCode = sotCode;
        this.startAppointment = startAppointment;
        this.endAppointment = endAppointment;
        this.phase = phase;
        this.note = note;
        this.outcome = outcome;
    }
}

export default class HdtTariAppointmentAgenda extends LightningElement {
    @api caseid;
    @api params;
    @track case;
    @track columns = COLUMNS;
    @track columnsView = COLUMNSVIEW;
    @track records = [];
    refreshRecord = false;
    disableConfirmButton = false;
    isCommunity = false;
    searchType;
    newDateLabel;
    selectedCode;
    showSpinner = true;
    @track fieldsToRetrieve;
    @track isView = false;

    @wire(getCase,{caseId : '$caseid', fields : '$fieldsToRetrieve'})
    wireRecord({error,data}){
        console.log(data);
        console.log(this.params);
        console.log(this.caseid);
        if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }
        if (data && this.params){
            this.case = JSON.parse(data);
                this.searchType = this.params.searchType;
                this.showSpinner = false;
                this.refreshRecord = false;
                if(this.params.searchType == 'View'){
                    this.getAppointmentDate();
                }else{
                    this.getNewDate();
                }
        }
    }
    
    connectedCallback(){
        
        if (this.params){
            if(this.params.searchType == 'View'){
                this.isView = true;
            }
            if (this.params.userCommunity === true || this.params.userCommunity === 'true'){
                this.isCommunity = true;
            }
            this.fieldsToRetrieve = OBJECT_FIELDS;
        }
    }

    confirmAppointment(){
        this.showSpinner = true;
        let row = this.template.querySelector('[data-id="dtAppointment"]').getSelectedRows();
        handleConfirm({
            caseId : this.caseid,
            appointmentJson : JSON.stringify(row[0])
        }).then(result =>{
            
            if (!result){
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
            }else{
                let data = JSON.parse(result);
                if(data.status.localeCompare('success') === 0){
                    this.showAlert('Operazione Riuscita','L\'appuntamento è stato confermato','success');
                    /*Alla pressione del pulsante “Conferma appuntamento”, viene inviato il flusso in uscita verso sap di conferma appuntamento TODO
                    this.case.AppointmentCode__c = result.AppointmentCode__c;
                    this.case.JobCenterCode__c = result.JobCenterCode__c; // da creare
                    this.case.SotCode__c = result.SotCode__c; //da creare
                    this.case.StartAppointment__c = result.StartAppointment__c; //da creare
                    this.case.EndAppointment__c = result.EndAppointment__c; //da creare
                    this.case.Phase__c = 'Da Inviare';
                    this.updateTheCase(this.case);
                    */

                    
                    // this.case.AppointmentCode__c = '1';
                    // this.case.JobCenterCode__c = '1';
                    // this.case.SotCode__c = '1';
                    this.case.StartAppointment__c = data.data.startDate;
                    this.case.EndAppointment__c = data.data.endDate;
                    this.case.Phase__c = 'Da Inviare';
                    this.case.Outcome__c ='Recived_Slots';

                    if(!this.case.WithdrawalFee__c){
                        let createdDate = this.case.CreatedDate.substring(0,10);
                        this.createWithdrawal(this.case.ServicePoint__c, createdDate);
                    }

                    var caseFields = new Objectfields(this.formatData(this.case.StartAppointment__c),this.formatData(this.case.EndAppointment__c),this.case.Phase__c,null,this.case.Outcome__c);

                    var activityFields = new Objectfields(this.formatData(this.case.StartAppointment__c),this.formatData(this.case.EndAppointment__c),null,null,null);

                    this.createNewActivityAndUpdateCase(this.case.Id, caseFields, null, activityFields);
                    this.refreshPage(true);
                }else{ 
                    this.showAlert('Errore','Impossibile confermare l\'appuntamento selezionato','error');
                    this.showSpinner = false;
                }
            }
        }).catch(error =>{
            this.showAlert('Errore',error.body.message,'error');
            this.dispatchEvent(new CustomEvent('cancelevent',{detail : this.refreshRecord}));
        });
    }

    createWithdrawal(servicePointId, createdDate){
        handleWithdrawalCreation({
            servicePointId : servicePointId,
            dataRitiro : createdDate
        }).then(result =>{
            console.log(' ### Ritiro Inserito');
        }).catch(error =>{
            this.showAlert('Errore',error.body.message,'error');
        });
    }

    createNewActivityAndUpdateCase(caseId, caseFields, templateName, activityFields){
        handleNewActivityCreationAndCaseUpdate({
            caseId : caseId,
            caseFields : JSON.stringify(caseFields),
            templateName : templateName,
            activityFields : JSON.stringify(activityFields)
        }).then(result =>{
            console.log(result);
        }).catch(error =>{
            this.showAlert('Errore',error.body.message,'error');
            this.dispatchEvent(new CustomEvent('cancelevent',{detail : this.refreshRecord}));
        });
    }


    handleClick(event){
        console.log('event.target.name ->' + event.target.name);

        if (event.target.name === 'Save'){
            if (this.isAppointmentSelected()){
                this.confirmAppointment();
            }else{
                this.showAlert('Attenzione','Selezionare un appuntamento','error');
            }
        }else if (event.target.name === 'Cancel'){
            this.isView = false;
            this.closeModal();
        }else if (event.target.name === 'newDate'){
            this.getNewDate();
        }
    }

    closeModal(){
        this.showSpinner = true;
        this.dispatchEvent(new CustomEvent('cancelevent',{detail : this.refreshRecord}));
        this.refreshPage(true);
    }

    getAppointmentDate(){
        this.handleViewMethod();
    }

    getNewDate(){
        let appointment = '2022-12-31';
        console.log('appointment ->' + appointment);
        let preferentialTime = '15:00/16:00';
        console.log('preferentialTime -> ' + preferentialTime);
        this.handleSearchMethod(appointment,preferentialTime);
    }

    handleViewMethod(){
        this.showSpinner = true;
        handleView({
            caseId : this.caseid
        }).then(result =>{
            if (!result){
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
            }else{
                let data = JSON.parse(result);
                if(data.status.localeCompare('success') === 0){
                    try{
                        let slots = data.data;
                        this.records = [];
                                this.addRecord({
                                    noticeNumber : slots.noticeNumber,
                                    appointmentType : slots.appointmentType,
                                    startDate : slots.startDate,
                                    endDate : slots.endDate
                                    // codice : element.codiceApp, 
                                    // data : this.formatData(element.appData), 
                                    // fascia : element.appFasciaOrario, 
                                    // stima: element.zStimaDurApp, 
                                    // dataLimite : this.formatData(element.zLimApp),
                                    // oraLimite : element.zLimAppOra 
                                });
                    }catch(e){
                        console.error(e);
                        this.showAlert('Attenzione','Errore nella chiamata al server. Non è stato ricevuto un appuntamento valido.','error');
                    }
                    this.showSpinner = false;
                    this.refreshRecord = false;
                }else{ 
                    this.showAlert('Errore','Si è verificato un errore','error');
                    this.showSpinner = false;
                }
            } 
        }).catch(error =>{
            this.showSpinner = false;
            this.showAlert('Attenzione',error.body.message,'error');
        });
    }

    handleSearchMethod(appointment,preferentialTime){
        this.showSpinner = true;
        handleSearch({
            caseId : this.caseid,
            searchType : 'FirstSearch',
            preferedDate : appointment,
            preferedTimeSlot : preferentialTime
        }).then(result =>{
            if (!result){
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
                this.disableConfirmButton = true; 
                this.createNewActivityAndUpdateCase(this.caseid, null, 'Contattare Cliente', null);
            }else{
                let data = JSON.parse(result);
                let slots = [];
                try{
                    slots = data.data.appointmentData;
                    this.records = [];
                    if(slots.length == 0){
                        this.case.Note__c = 'l’appuntamento non può essere preso perché l’agenda non restituisce alcuna data - ricontattare il cliente';
                        this.case.Outcome__c ='Empty_Slots';
                        var caseFields = new Objectfields(null,null,null,null,null,null,this.case.Note__c,this.case.Outcome__c);
                        this.disableConfirmButton = true; 
                    }else{
                        slots.forEach(element => {
                            this.addRecord({
                                outcome : slots.outcome,
                                text : slots.text,
                                startDate : element.startDate,
                                endDate : element.endDate
                            });
                        });
                        this.case.Outcome__c='Recived_Slots';
                        var caseFields = new Objectfields(null,null,null,null,null,null,null,this.case.Outcome__c);
                        this.createNewActivityAndUpdateCase(this.caseid, caseFields, null, null);
                        this.disableCancelButton = false; 
                    }
                }catch(e){
                    console.error(e);
                    this.showAlert('Attenzione','Errore nella chiamata al server. Non è stato ricevuto un appuntamento valido.','error');
                }
                this.showSpinner = false;
                this.refreshRecord = false;
            } 
        }).catch(error =>{
            this.showSpinner = false;
            this.showAlert('Attenzione',error.body.message,'error');
        });
    }

    isAppointmentSelected(){
        try{
            let row = this.template.querySelector('[data-id="dtAppointment"]').getSelectedRows();
            if (row.length > 0 ){
                this.selectedCode = row.codice;
                return true;
            }else{
                return false;
            }
        }catch(e){
            console.error(e);
            return false;
        }
        
    }

    showAlert(_title,_message,_variant){
        console.log('is community ' + this.isCommunity);
        if (this.isCommunity){
            alert(_message);
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: _title,
                    message: _message,
                    variant: _variant
                })
            );
        }  
    }

    async refreshPage(flagCommunity){
        let userCommunity;
        if (!flagCommunity){
            setTimeout(function(){window.location.reload()},3000);
        }else{
            userCommunity = flagCommunity;
            this.dispatchEvent(new CustomEvent('cancelevent',{detail : true}));
        }
    }

    addRecord(element){
        this.records = [...this.records,element];
    }
 
    formatData(dateToFormat){
        let dataToWork = dateToFormat.split('-');
        return dataToWork[2]+'/'+(dataToWork[1])+'/'+dataToWork[0];
    }

}