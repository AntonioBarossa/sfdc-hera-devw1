import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleSearch from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleSearch';
import handleView from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleView';
import handleConfirm from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleConfirm';
import getCase from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.getCase';
import handleNewActivityCreationAndCaseUpdate from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.handleNewActivityCreationAndCaseUpdate';
import {equalsIgnoreCase} from 'c/hdtChildOrderProcessDetailsUtl';


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
    'SupplyStreetNumber__c',
    'SupplyStreetCode__c',
    'InvoicingPostalCode__c',
    'InvoicingStreetNumber__c',
    'InvoicingStreetName__c',
    'InvoicingCity__c',
    'InvoicingStreetCode__c',
    'TypeOperation__c'
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

class Wrapper{
    constructor(purchaseOrderNumber,streetCoding,street,housenumber,typeInt, city, indicator, numberOfLines){
        this.purchaseOrderNumber = purchaseOrderNumber;
        this.streetCoding = streetCoding;
        this.street = street;
        this.housenumber = housenumber;
        this.indicator = indicator;
        this.city = city;
        this.typeInt = typeInt?.toUpperCase();
        this.numberOfLines = numberOfLines;

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
    @track fieldsToRetrieve=OBJECT_FIELDS;
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
            this.case = data;
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
        }
    }

    confirmAppointment(){
        this.showSpinner = true;
        let row = this.template.querySelector('[data-id="dtAppointment"]').getSelectedRows();
        const wrap = this.createWrapper();
        wrap.startDate=row.startDate;
        wrap.endDate=row.endDate;
        handleConfirm({
            theCase : this.case,
            wrap : wrap
        }).then(result =>{
            
            if (!equalsIgnoreCase(result?.status, 'success')){
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
            }else{
                //let data = JSON.parse(result);
                let data = result;
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

    createNewActivityAndUpdateCase(caso, updateCase, templateName){
        handleNewActivityCreationAndCaseUpdate({
            caso : caso,
            updateCase : updateCase,
            templateName : templateName
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
        const wrap = this.createWrapper();
        this.handleSearchMethod(wrap);
    }

    createWrapper(){
        let purchaseOrderNumber = this.caseid;
        let streetCoding = this.case.InvoicingStreetCode__c
        let housenumber = this.case.InvoicingStreetNumber__c
        let typeInt = this.case.TypeOperation__c;
        let indicator = '';
        let numberOfLines = '';
        let city = this.case.InvoicingCity__c;
        let street = `${this.case.InvoicingStreetName__c}, ${housenumber} ${this.case.InvoicingPostalCode__c} ${city}`;

        return new Wrapper(purchaseOrderNumber, streetCoding, street, housenumber, typeInt, city, indicator, numberOfLines);
    }

    handleViewMethod(){
        this.showSpinner = true;
        handleView({
            purchaseOrderNumber : this.caseid
        }).then(result =>{
            if (!equalsIgnoreCase(result?.status, 'success')){
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
            }else{
                //let data = JSON.parse(result);
                let data = result;
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

    handleSearchMethod(wrap){
        this.showSpinner = true;
        handleSearch({
            wrap : wrap
        }).then(result =>{
            if(!equalsIgnoreCase(result?.status, 'success')){ 
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
                this.disableConfirmButton = true; 
                this.createNewActivityAndUpdateCase(this.case, false, 'Contattare Cliente');
            }else{
                //let data = JSON.parse(result);
                let data = result;
                let slots = [];
                try{
                    slots = data.data.appointmentData;
                    this.records = [];
                    if(slots.length == 0){
                        this.case.Note__c = 'l’appuntamento non può essere preso perché l’agenda non restituisce alcuna data - ricontattare il cliente';
                        this.case.Outcome__c ='Empty_Slots';
                        this.disableConfirmButton = true; 
                    }else{
                        slots.forEach(element => {
                            this.addRecord({
                                startDate : element.startDate,
                                endDate : element.endDate
                            });
                        });
                        this.case.Outcome__c='Recived_Slots';
                        this.createNewActivityAndUpdateCase(this.case, true, null);
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