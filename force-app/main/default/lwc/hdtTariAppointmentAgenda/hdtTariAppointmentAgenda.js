import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleSearch from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleSearch';
import handleView from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleView';
import handleConfirm from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleConfirm';
import getCase from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.getCase';
import handleNewActivityCreationAndCaseUpdate from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleNewActivityCreationAndCaseUpdate';


const OBJECT_FIELDS =[
    'CaseNumber',
    'Outcome__c',
    'StartAppointment__c',
    'EndAppointment__c',
    'WithdrawalFee__c',
    'ServicePoint__c',
    'CreatedDate',
    'SupplyPostalCode__c',
    'SupplyStreetName__c',
    'InvoicingStreetCode__c'
];

const COLUMNS = [
    { label: 'Data Inizio Appuntamento', fieldName: 'startDate', type: 'text' },
    { label: 'Data Fine Appuntamento', fieldName: 'endDate', type: 'text' },
];

const COLUMNSVIEW = [
    { label: 'noticeNumber', fieldName: 'noticeNumber', type: 'text' },
    { label: 'appointmentType', fieldName: 'appointmentType', type: 'text' },
    { label: 'Data Inizio Appuntamento', fieldName: 'startDate', type: 'text' },
    { label: 'Data Fine Appuntamento', fieldName: 'endDate', type: 'text' },
];

class Objectfields{
    constructor(startAppointment,endAppointment,phase,note,outcome){
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
            case : this.case,
            purchaseOrderNumber : this.caseid,
            streetCoding : this.case.SupplyPostalCode__c,
            street : this.case.SupplyStreetName__c,
            housenumber : this.case.InvoicingStreetCode__c,
            typeInt : null,
            indicator : null,
            numberOfLines : null,
            startDate : row.startDate,
            endDate : row.endDate
        }).then(result =>{
            
            if (!result?.status == 'success'){
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
            }else{
                let data = JSON.parse(result);
                if(data.status.localeCompare('success') === 0){
                    this.showAlert('Operazione Riuscita','L\'appuntamento è stato confermato','success');
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
        let purchaseOrderNumber = this.caseid;
        let streetCoding = '';
        let street = '';
        let housenumber = '';
        let typeInt = '';
        let indicator = '';
        let numberOfLines = '';

        this.handleSearchMethod(purchaseOrderNumber, streetCoding, street, housenumber,typeInt, indicator, numberOfLines);
    }

    handleViewMethod(){
        this.showSpinner = true;
        handleView({
            purchaseOrderNumber : this.caseid
        }).then(result =>{
            if (!result?.status == 'success'){
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

    handleSearchMethod(purchaseOrderNumber, streetCoding, street, housenumber,typeInt, indicator, numberOfLines){
        this.showSpinner = true;
        handleSearch({
            purchaseOrderNumber : purchaseOrderNumber,
            streetCoding : streetCoding, 
            street : street, 
            housenumber : housenumber, 
            typeInt : typeInt, 
            indicator : indicator, 
            numberOfLines : numberOfLines
        }).then(result =>{
            if(!result?.status == 'success'){ 
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
                        var caseFields = new Objectfields(null,null,null,this.case.Note__c,this.case.Outcome__c);
                        this.disableConfirmButton = true; 
                    }else{
                        slots.forEach(element => {
                            this.addRecord({
                                startDate : element.startDate,
                                endDate : element.endDate
                            });
                        });
                        this.case.Outcome__c='Recived_Slots';
                        var caseFields = new Objectfields(null,null,null,null,this.case.Outcome__c);
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
        if (!flagCommunity){
            setTimeout(function(){window.location.reload()},3000);
        }else{
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